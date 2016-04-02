/*
 *  This file is part of the TVShows source code.
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

#import "SubscriptionManager.h"

#import "Serie.h"
#import "Subscription.h"
#import "Episode.h"

#import "RARBG.h"
#import "TheTVDB.h"

@import libextobjc;
@import AFNetworking;
@import MagicalRecord;

@interface SubscriptionManager ()

@property (strong, nonatomic) SubscriptionID *subscriptionID;

@end

@implementation SubscriptionManager

#pragma mark - Public

// [1] Check subscription for new episodes.
- (void)checkSubscription:(Subscription *)subscription {
    self.subscriptionID = subscription.objectID;
    
    //Debug
    [self.managedObjectContext MR_setWorkingName:[NSString stringWithFormat:@"SubscriptionManager Context (Serie: %@)", subscription.serie.serieID]];
    
    NSNumber *serieID = subscription.serie.serieID;
    
    //TODO: Only update a serie on new episode day or if subscription.lastDownload is longer than a week.
    
    // Update episodes.
    [[TVDBManager manager] episodes:serieID completionBlock:^(NSArray<TVDBEpisode *> *episodes) {
        NSInvocationOperation *updateOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                      selector:@selector(updateEpisodes:)
                                                                                        object:episodes];
        [self.operationQueue addOperation:updateOperation];
    } failure:^(NSError *error) {
        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
    }];
}

#pragma mark - Private

// [2] Save the episodes.
- (void)updateEpisodes:(NSArray<TVDBEpisode *> *)episodes {
    Subscription *subscription = [self.managedObjectContext objectWithID:self.subscriptionID];
    
    NSError *modelError;
    TVDBSerie *serie = [TVDBSerie modelFromManagedObject:subscription.serie error:&modelError];
    
    if (modelError) {
        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, modelError);
        return;
    }
    
    [serie addEpisodes:episodes];
    
    NSError *moError;
    __unused Serie *s = [serie insertManagedObjectIntoContext:self.managedObjectContext error:&moError];
    
    if (moError) {
        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, moError);
        return;
    }
    
    [self.managedObjectContext MR_saveWithOptions:MRSaveParentContexts completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSInvocationOperation *updateOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                      selector:@selector(downloadEpisodes)
                                                                                        object:nil];
        [self.operationQueue addOperation:updateOperation];
    }];
}

// [3] Search for episodes not downloaded yet.
- (void)downloadEpisodes {
    Subscription *subscription = [self.managedObjectContext objectWithID:self.subscriptionID];
    
    // All Episodes from serie, and marked as not downloaded.
    NSPredicate *seriePredicate = [NSPredicate predicateWithFormat:@"serie = %@", subscription.serie];
    NSPredicate *notDownloaded = [NSPredicate predicateWithFormat:@"downloaded = false"];
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[seriePredicate, notDownloaded]];
    
    NSArray<Episode *> *episodes = [Episode findAllWithPredicate:predicate inContext:self.managedObjectContext];
    
    [episodes enumerateObjectsUsingBlock:^(Episode *episode, NSUInteger idx, BOOL *stop) {
        // Download the serie.
        NSString *search = [subscription searchNameForEpisode:episode];
        RARBGSearchOperation *downloadOperation = [[RARBGClient manager] search:search];
        
        @weakify(episode)
        [downloadOperation setCompletionBlockWithSuccess:^(RARBGSearchOperation *operation, NSArray<RARBGTorrent *> *torrents) {
            @strongify(episode)
            
            if (torrents.count == 0) {
                DDLogInfo(@"No results found");
            } else {
                [self processTorrent:torrents[0] Episode:episode];
            }
        } failure:^(RARBGSearchOperation *operation, NSError *error) {
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
        }];
    }];
}

// [4] Open the torrent, and update the Episode as downloaded.
- (void)processTorrent:(RARBGTorrent *)torrent Episode:(Episode *)episode {
    // Open the magnet link
    [TorrentClient openTorrent:torrent.magnet];
    
    // Mark the episode as downloaded, update subscription's lastDownloaded
    [self.managedObjectContext performBlock:^{
        Subscription *subscription = [self.managedObjectContext objectWithID:self.subscriptionID];
        subscription.lastDownloaded = [NSDate date];
        
        episode.downloaded = @true;
        
        [self.managedObjectContext MR_saveWithOptions:MRSaveParentContexts completion:nil];
    }];
    
    // Show notification
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"New Episode Downloaded";
    notification.subtitle = [NSString stringWithFormat:@"%@ %@", episode.serie.name, episode.fullEpisodeNumber];
    notification.identifier = [@"TVShows.Helper.notification.NewEpisode." stringByAppendingPathExtension:episode.episodeID.stringValue];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

#pragma mark - Lifecycle

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    
    if (self) {
        self.managedObjectContext = [NSManagedObjectContext contextWithParent:managedObjectContext];
    }
    
    return self;
}

- (NSOperationQueue *)operationQueue {
    static NSOperationQueue *operationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.name = @"TVShows.Helper.SubscriptionManager.Queue";
    });
    return operationQueue;
}

@end
