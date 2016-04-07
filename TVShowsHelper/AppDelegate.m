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
    
    // Core Data
    [self setupCoreData];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.managedObjectContext = [NSManagedObjectContext defaultContext];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    [self setupTimer];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [MagicalRecord cleanUp];
}

#pragma mark - NSUserNotificationCenterDelegate

// User clicked on a notification.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    // Remove the notification from the notification center
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:notification];
}

#pragma mark - Private

- (void)checkAllShows {
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = @"TVShows";
    notification.subtitle = @"Checking for new episodes...";
    notification.identifier = @"TVShows.Helper.notification.checkAllShows";
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    // Fetch all Subscription enabled.
    NSFetchRequest *fetchRequest = [Subscription requestAllWhere:@"isEnabled" isEqualTo:@YES inContext:self.managedObjectContext];
    
    @autoreleasepool {
        NSArray *result = [Subscription executeFetchRequest:fetchRequest inContext:self.managedObjectContext];
        
        [result enumerateObjectsUsingBlock:^(Subscription *subscription, NSUInteger idx, BOOL *stop) {
            SubscriptionManager *sm = [[SubscriptionManager alloc] initWithManagedObjectContext:self.managedObjectContext];
            [sm checkSubscription:subscription];
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

#pragma mark - Setup 

- (void)setupTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSTimeInterval interval = [self userDelay];
        interval = 30;
        
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:60]// Wait 1m to start.
                                              interval:interval
                                                target:self
                                              selector:@selector(checkAllShows)
                                              userInfo:nil
                                               repeats:YES];
        
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        
        // The receiver retains the timer. To remove a timer from all run loop modes on which it is installed, send an invalidate message to the timer.
        [currentRunLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
        [currentRunLoop run];
    });
}

@end
