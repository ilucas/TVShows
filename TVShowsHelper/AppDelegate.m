//
//  AppDelegate.m
//  TVShowsHelper
//
//  Created by Lucas casteletti on 2/9/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

#import "AppDelegate.h"

#import "Serie.h"
#import "Subscription.h"

#import "RARBGClient.h"

@import AFNetworking;

@interface AppDelegate ()

@property NSTimer *timer;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

// Providers
@property (strong, nonatomic) RARBGClient *rarbg;

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
    self.context = [NSManagedObjectContext context];
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    
    [self setupTimer];
    [self setupProviders];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [MagicalRecord cleanUp];
}

#pragma mark - Private

- (void)checkAllShows {
    NSFetchRequest *fetchRequest = [Subscription requestAllWhere:@"isEnabled" isEqualTo:@YES inContext:self.context];
    
    @autoreleasepool {
        __unused NSArray *result = [Subscription executeFetchRequest:fetchRequest inContext:self.context];
        
//        [result enumerateObjectsUsingBlock:^(Subscription *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            SubscriptionID *objID = [obj objectID];
//        }];
        
    }
}

- (NSTimeInterval)userDelay {
    NSUserDefaults __weak *userDefaults = [self sharedUserDefaults];
    
    NSInteger delay = [userDefaults floatForKey:@"checkDelay"];;
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

- (void)setupProviders {
    self.rarbg = [[RARBGClient alloc] init];
    self.rarbg.operationQueue = self.operationQueue;
}

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
