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
@import CocoaLumberjack;
@import MagicalRecord;
@import Crashlytics;
@import LetsMove;
@import Fabric;

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()

@property (weak) NSWindow *mainWindow;

@end

@implementation AppDelegate

- (void)awakeFromNib {
    // Log
    [self setupLogging];
    
    // Crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    // Core Data
    [self setupCoreData];
    
    // Cache
    [self setupCache];
}

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"NSApplicationCrashOnExceptions": @YES}];
    
    // Let's Move
    PFMoveToApplicationsFolderIfNecessary();
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Keep a reference to the main application window
    self.mainWindow = NSApp.windows.lastObject;
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
    [self.mainWindow makeKeyAndOrderFront:self];
    
    return false;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext defaultContext];
    
    if (![defaultContext commitEditing]) {
        DDLogError(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (defaultContext.hasChanges) {
        [defaultContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            if (contextDidSave) {
                [NSApp replyToApplicationShouldTerminate:YES];
            } else {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
                alert.informativeText = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
                [alert addButtonWithTitle:NSLocalizedString(@"Quit anyway", @"Quit anyway button title")];
                [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button title")];
                [alert setAlertStyle:NSCriticalAlertStyle];
                
                if (sender.mainWindow) {
                    [alert beginSheetModalForWindow:sender.mainWindow completionHandler:^(NSModalResponse returnCode) {
                        [NSApp replyToApplicationShouldTerminate:(returnCode == NSAlertFirstButtonReturn)];
                    }];
                } else {
                    NSModalResponse returnCode = [alert runModal];
                    [NSApp replyToApplicationShouldTerminate:(returnCode == NSAlertFirstButtonReturn)];
                }
            }
        }];
        
        return NSTerminateLater;
    }
    
    return NSTerminateNow;
}

#pragma mark - Setup

- (void)setupCache {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*1 // 1MB mem cache
                                                         diskCapacity:1024*1024*20 // 20MB disk cache
                                                             diskPath:self.applicationCacheDirectory];
    [NSURLCache setSharedURLCache:URLCache];
}

#pragma mark - Actions

- (void)openPreferences {
    NSEvent *event = [NSEvent keyEventWithType:NSKeyDown
                                      location:NSZeroPoint
                                 modifierFlags:NSCommandKeyMask
                                     timestamp:[NSDate timeIntervalSinceReferenceDate]
                                  windowNumber:[[NSApp mainWindow] windowNumber]
                                       context:[NSGraphicsContext currentContext]
                                    characters:@","
                   charactersIgnoringModifiers:@","
                                     isARepeat:NO
                                       keyCode:0x37];// kVK_Command
    
    [[NSApp mainMenu] performKeyEquivalent:event];
}

@end
