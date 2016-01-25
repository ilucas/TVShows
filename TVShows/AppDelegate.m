//
//  AppDelegate.m
//  TVShows
//
//  Created by Lucas on 10/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import AFNetworkActivityLogger;

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (strong) MainWindowController *mainWindowController;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    // Log
    [self setupLogging];
    
    // Core Data
    [self setupCoreData];
    
    // Cache
    [self setupCache];
    
    // Main Window init
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainWindowController = [storyBoard instantiateInitialController];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.mainWindowController.window center];
    [self.mainWindowController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [MagicalRecord cleanUp];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)hasVisibleWindows {
    
    if (hasVisibleWindows) {
        // some window may not be visible, so let NSApplication do his thing.
        return true;
    }
    
    // If there's no window visible, show the main window.
    [self.mainWindowController showWindow:sender];
    
    return false;
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
