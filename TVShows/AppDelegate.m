//
//  AppDelegate.m
//  TVShows
//
//  Created by Lucas on 10/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import AFNetworkActivityLogger;

#import "AppDelegate.h"
#import "SubscriptionWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (strong) SubscriptionWindowController *subscriptionWindow;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Log
    [self setupLogging];

    // Core Data
    [self setupCoreData];
    
    // Cache
    [self setupCache];
    
    _subscriptionWindow = [SubscriptionWindowController new];
    
    [self asas:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [MagicalRecord cleanUp];
}

#pragma mark - DEBUG

- (IBAction)asas:(id)sender {
    [_window beginSheet:[_subscriptionWindow window] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

#pragma mark - Setup

- (void)setupCache {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0 // 1MB mem cache
                                                         diskCapacity:1024*1024*15 // 15MB disk cache
                                                             diskPath:applicationCacheDirectory()];
    [NSURLCache setSharedURLCache:URLCache];
}

- (void)setupLogging {
    // Setup logging into XCode's console
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup AFNetworking log
    AFNetworkActivityLogger *afLogger = [AFNetworkActivityLogger sharedLogger];
    [afLogger setLevel:AFLoggerLevelInfo];
    [afLogger startLogging];
    
    // Setup logging to rolling log files
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setRollingFrequency:60 * 60 * 24]; // Roll logs every day
    [fileLogger setMaximumFileSize:1024 * 1024 * 2]; // max 2 mb
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:7]; // Keep 7 days only
    [DDLog addLogger:fileLogger];
}

- (void)setupCoreData {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelAll];
    [MagicalRecord enableShorthandMethods];
}

@end
