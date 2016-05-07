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

#import "SubscriptionViewController.h"
#import "MetadataViewController.h"
#import "EpisodesViewController.h"
#import "TheTVDB.h"
#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

@interface SubscriptionViewController ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation SubscriptionViewController

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.showList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    TVDBSerie *serie = self.showList[row];
    return serie.name;
}

- (TVDBSerie *)selectedShow {
    NSInteger selectedRow = self.showsTableView.selectedRow;
    
    if (selectedRow < 0) {
        return nil;
    }
    
    return self.showList[selectedRow];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.showList.count <= 0) return;
    
    TVDBSerie __block *selectedObject = [self selectedShow];
    
    [self.metadataViewController resetView];
    [self.episodesViewController resetView];
    
    if (selectedObject) {
        // download serie info.
        [self.metadataViewController toggleLoading:YES];
        
        NSNumber *serieID = selectedObject.serieID;
        
        // Get Serie
        [[TVDBManager manager] serie:serieID completionBlock:^(TVDBSerie *tvdbSerie) {
            NSError *error;
            Serie *serie = [tvdbSerie insertManagedObjectIntoContext:self.managedObjectContext error:&error];
            
            if (error) {
                DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
            }
            
            [self updateShowInfo:serie.objectID];
            [self.metadataViewController toggleLoading:NO];
        } failure:^(NSError * _Nonnull error) {
            [self.metadataViewController toggleLoading:NO];
            [self updateShowInfo:nil];
            
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        }];
        
        // Get Episodes
        [[TVDBManager manager] episodes:serieID completionBlock:^(NSArray<TVDBEpisode *> *episodes) {
            [self.episodesViewController updateEpisodes:episodes];
            
            Serie *s = [Serie findFirstByAttribute:@"serieID" withValue:serieID inContext:self.managedObjectContext];
            
            NSError *modelError;
            TVDBSerie *serie = [TVDBSerie modelFromManagedObject:s error:&modelError];
            
            if (modelError) {
                DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, modelError);
            }
            
            [serie addEpisodes:episodes];
            
            NSError *error;
            [serie insertManagedObjectIntoContext:self.managedObjectContext error:&error];
            
            if (error) {
                DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
            }
        } failure:^(NSError * _Nonnull error) {
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
            [self.metadataViewController toggleLoading:NO];
            [self updateShowInfo:nil];
            
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        }];
    }
}

#pragma mark - Actions

- (IBAction)closeWindow:(id)sender {
    [self reset];
    [self dismissViewController:self];
}

- (IBAction)subscribeToShow:(id)sender {
    TVDBSerie *selectedObject = [self selectedShow];
    if (!selectedObject) return;
    
    NSString *quality = [[self.showQuality.titleOfSelectedItem split:@" "] firstObject];
    NSArray<NSNumber *> *selectedEpisodes = [[self.episodesViewController selectedEpisodes] map:^id(TVDBEpisode *ep) {
        return ep.episodeID;
    }];
    
    [self.managedObjectContext MR_saveWithBlock:^(NSManagedObjectContext *localContext) {
        Serie *serie = [Serie findFirstByAttribute:@"serieID" withValue:selectedObject.serieID inContext:localContext];
        
        [serie.episodes enumerateObjectsUsingBlock:^(Episode *episode, BOOL *stop) {
            // If the episode is not in the selected list, mark as downloaded.
            episode.downloaded = [selectedEpisodes containsObject:episode.episodeID] ? @NO : @YES;
        }];
        
        Subscription *subscription = [Subscription createEntityInContext:localContext];
        [subscription setIsEnabledValue:YES];
        [subscription setQuality:quality];
        [subscription setSerie:serie];
    } completion:^(BOOL contextDidSave, NSError *error) {
        if (error) {
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        }
        
        // Close window after subscribe to show.
        [self closeWindow:nil];
    }];
}

- (IBAction)search:(id)sender {
    NSString *search = self.searchField.stringValue;
    
    if ([search isEmpty]) {
        [self.showList removeAllObjects];
        [self.showsTableView reloadData];
        return;
    }
    
    [[TVDBManager manager] searchSerie:search completionBlock:^(NSArray<TVDBSerie *> * _Nonnull series) {
        [self.showList removeAllObjects];
        [self.showList addObjectsFromArray:series];
        [self.showsTableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        
        if (response.statusCode != 404) {
            [self.showList removeAllObjects];
            [self.showsTableView reloadData];
            
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
        }
    }];
}

#pragma mark - Private

- (void)updateShowInfo:(SerieID *)serieID {
    Serie *serie = [self.managedObjectContext objectWithID:serieID];
    
    [self.metadataViewController updateShowInfo:serie];
    
    // Disable subscribe button if already subscribed.
    if ([self userIsSubscribedToShow:serie]) {
        [self.subscribeButton setEnabled:NO];
        [self.subscribeButton setTitle:@"Subscribed"];
    } else {
        [self.subscribeButton setEnabled:YES];
        [self.subscribeButton setTitle:@"Subscribe"];
    }
}

- (void)reset {
    [self.metadataViewController resetView];
    [self.episodesViewController resetView];
    
    //Clean the search field
    [self.searchField setStringValue:@""];
    
    //Empty the series tableview
    [self.showList removeAllObjects];
    [self.showsTableView reloadData];
}

- (BOOL)userIsSubscribedToShow:(Serie *)serie {
    NSUInteger __block count;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serie = %@", serie];
        count = [[Subscription numberOfEntitiesWithPredicate:predicate inContext:self.managedObjectContext] unsignedIntegerValue];
    }];
    
    return count;
}

#pragma mark - LifeCicle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showList = [NSMutableArray array];
    self.managedObjectContext = [NSManagedObjectContext defaultContext];
    
    if (![[TVDBManager manager] token]) {
        [[TVDBManager manager] requestToken];
    }
}

@end
