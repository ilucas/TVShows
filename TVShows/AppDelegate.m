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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    _subscriptionWindow = [SubscriptionWindowController new];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)asas:(id)sender {
    [_window beginSheet:[_subscriptionWindow window] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}


@end
