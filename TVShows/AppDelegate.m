//
//  AppDelegate.m
//  TVShows
//
//  Created by Lucas on 10/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "AppDelegate.h"
#import "SubscriptionWindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (strong) SubscriptionWindowController *subscriptionWindow;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Core Data
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    // Cache
    [self setupCache];
    
    _subscriptionWindow = [SubscriptionWindowController new];
    
    
    
    [self asas:nil];
    
//    NSString *showName = @"dexter";
//    NSString *TVDBBaseURL = @"http://www.thetvdb.com";
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [MagicalRecord cleanUp];
}

- (IBAction)asas:(id)sender {
    [_window beginSheet:[_subscriptionWindow window] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

#pragma mark - Private

- (void)setupCache {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0 // 1MB mem cache
                                                         diskCapacity:1024*1024*100 // 100MB disk cache
                                                             diskPath:applicationCacheDirectory()];
    [NSURLCache setSharedURLCache:URLCache];
}

@end
