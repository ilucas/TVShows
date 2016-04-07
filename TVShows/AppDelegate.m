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

@import AFNetworkActivityLogger;
@import LetsMove;

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()

@property (strong) MainWindowController *mainWindowController;
@property (nonatomic, strong) NSWindowController *preferencesWindowController;
@property (nonatomic, strong) AboutWindowController *aboutWindowController;

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
    
    // Let's Move
    PFMoveToApplicationsFolderIfNecessary();
    
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

#pragma mark - Actions

- (IBAction)showAboutWindow:(id)sender {
    if (!self.aboutWindowController) {
        self.aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    }
    
    [self.aboutWindowController.window center];
    [self.aboutWindowController showWindow:nil];
}

- (IBAction)showPreferencesWindow:(id)sender {
    if (!self.preferencesWindowController) {
        NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Preferences" bundle:nil];
        self.preferencesWindowController = [storyBoard instantiateInitialController];
    }
    
    [self.preferencesWindowController showWindow:nil];
}

#pragma mark - Setup

- (void)setupCache {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*1 // 1MB mem cache
                                                         diskCapacity:1024*1024*15 // 15MB disk cache
                                                             diskPath:applicationCacheDirectory()];
    [NSURLCache setSharedURLCache:URLCache];
}

@end
