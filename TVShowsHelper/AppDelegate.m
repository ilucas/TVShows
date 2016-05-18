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

#import "AppDelegate.h"

#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

#import "SubscriptionManager.h"
#import "TheTVDB.h"

@import Fabric;
@import Crashlytics;
@import AFNetworking;
@import MagicalRecord;

@interface AppDelegate ()

@property NSTimer *timer;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    // Log
    [self setupLogging];
    
    // Crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    // Core Data
    [self setupCoreData];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"NSApplicationCrashOnExceptions": @YES}];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.managedObjectContext = [NSManagedObjectContext defaultContext];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    NSDistributedNotificationCenter *distributedCenter = [NSDistributedNotificationCenter defaultCenter];
    
    [distributedCenter addObserver:self
                          selector:@selector(reloadTimer:)
                              name:@"TVShows.Notification.DelayChanged"
                            object:nil];
    
    [distributedCenter addObserver:self
                          selector:@selector(checkShow:)
                              name:@"TVShows.Notification.CheckNewEpisodes"
                            object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(reloadTimer:)
                                                               name:NSWorkspaceDidWakeNotification
                                                             object:nil];
    [self setupTimer];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Remove Notifications observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
    // Core Data clanup
    [MagicalRecord cleanUp];
}

#pragma mark - NSUserNotificationCenterDelegate

// User clicked on a notification.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    // Remove the notification from the notification center
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:notification];
    
//    if (![notification.identifier isEqualToString:@"TVShows.Helper.notification.checkAllShows"]) {
//        // Open TVShows
//    }
}

#pragma mark - Private

- (void)checkAllShows {
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = @"TVShows";
    notification.subtitle = @"Checking for new episodes...";
    notification.identifier = @"TVShows.Helper.notification.checkAllShows";
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    DDLogInfo(@"Checking for new episodes.");
    
    // Fetch all Subscription enabled.
    NSFetchRequest *fetchRequest = [Subscription requestAllWhere:@"isEnabled" isEqualTo:@YES inContext:self.managedObjectContext];
    
    @autoreleasepool {
        NSArray *result = [Subscription executeFetchRequest:fetchRequest inContext:self.managedObjectContext];
        
        [result enumerateObjectsUsingBlock:^(Subscription *subscription, NSUInteger idx, BOOL *stop) {
            SubscriptionManager *sm = [[SubscriptionManager alloc] initWithManagedObjectContext:self.managedObjectContext];
            [sm checkSubscription:subscription];
        }];
    }
    
    [[self sharedUserDefaults] setObject:[NSDate date] forKey:@"lastCheckedForEpisodes"];
}

- (void)checkShow:(NSNotification *)notification {
    NSArray<NSNumber *> *seriesID = notification.userInfo[@"serieID"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serie.serieID IN %@", seriesID];
    NSArray *result = [Subscription findAllWithPredicate:predicate inContext:self.managedObjectContext];
    
    NSUserNotificationCenter *userNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    @autoreleasepool {
        [result enumerateObjectsUsingBlock:^(Subscription *subscription, NSUInteger idx, BOOL *stop) {
            SubscriptionManager *sm = [[SubscriptionManager alloc] initWithManagedObjectContext:self.managedObjectContext];
            [sm checkSubscription:subscription];
            
            Serie *serie = subscription.serie;
            
            DDLogInfo(@"Checking for new episodes: %@ (%@)", serie.name, serie.serieID);
            
            NSUserNotification *notification = [NSUserNotification new];
            notification.title = serie.name;
            notification.subtitle = @"Checking for new episodes...";
            notification.identifier = [@"TVShows.Helper.notification.checkShow." stringByAppendingString:serie.serieID.stringValue];
            
            [userNotificationCenter deliverNotification:notification];
        }];
    }
}

- (NSTimeInterval)userDelay {
    NSUserDefaults __weak *userDefaults = [self sharedUserDefaults];
    
    NSInteger delay = [userDefaults integerForKey:@"checkDelay"];
    NSTimeInterval seconds;
    
    switch (delay) {
        case 0:
            // 30 minutes
            seconds = 30*60;
            break;
        case 1:
            // 1 hour
            seconds = 1*60*60;
            break;
        case 2:
            // 3 hours
            seconds = 3*60*60;
            break;
        case 3:
            // 6 hours
            seconds = 6*60*60;
            break;
        case 4:
            // 12 hours
            seconds = 12*60*60;
            break;
        case 5:
            // 1 day
            seconds = 24*60*60;
            break;
        default:
            // 1 hour
            seconds = 1*60;
    }
    
    return seconds;
}

#pragma mark - RunLoop

- (void)reloadTimer:(NSNotification *)notification {
    if (notification) {
        DDLogInfo(@"[%@] {object = %@, userInfo = %@}", notification.name, notification.object, notification.userInfo);
    }
    
    // The receiver retains the timer.
    // To remove a timer from all run loop modes on which it is installed, send an invalidate message to the timer.
    [self.timer invalidate];
    
    [self setupTimer];
}

- (void)setupTimer {
    NSDate *lastCheck = [[self sharedUserDefaults] objectForKey:@"lastCheckedForEpisodes"] ?: [NSDate date];
    
    NSTimeInterval userDelay = [self userDelay];
    NSTimeInterval nextCheck = (userDelay - [[NSDate date] timeIntervalSinceDate:lastCheck]);
    
    // If the next should already be done, do it now
    if (nextCheck < 0.1) {
        // Wait a little for connecting to the network
        nextCheck = 60;
    }
    
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:nextCheck]
                                          interval:userDelay
                                            target:self
                                          selector:@selector(checkAllShows)
                                          userInfo:nil
                                           repeats:YES];
    
    DDLogInfo(@"------------ Timer Setup ------------");
    DDLogInfo(@"Last Check: %@", lastCheck);
    DDLogInfo(@"Next Check: %@", self.timer.fireDate);
    DDLogInfo(@"User Delay: %g Seconds", userDelay);
    DDLogInfo(@"-------------------------------------");
    
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

@end
