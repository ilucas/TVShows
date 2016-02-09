//
//  AppDelegate.h
//  TVShows
//
//  Created by Lucas on 11/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Cocoa;

#import "TSAppDelegate.h"

@interface AppDelegate : TSAppDelegate <NSApplicationDelegate>

- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;

@end

