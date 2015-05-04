//
//  AppDelegate.m
//  TVShows
//
//  Created by Lucas on 10/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [MagicalRecord setupCoreDataStack];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
