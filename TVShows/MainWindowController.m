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

#import "MainWindowController.h"
#import "GridViewController.h"

@implementation MainWindowController

#pragma mark - Lifecycle

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setUpWindow];
}

#pragma mark - Override

- (IBAction)showWindow:(nullable id)sender {
    [super showWindow:sender];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {

}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect {
    rect.origin.y -= 37;
    return rect;
}

// Tells the delegate that the window has closed a sheet.
- (void)windowDidEndSheet:(NSNotification *)notification {
    GridViewController *gridView = (GridViewController *)[self contentViewController];
    [gridView reloadData];
}

- (void)setUpWindow {
    self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent  = YES;
    self.window.movableByWindowBackground = YES;
    self.window.styleMask |= NSFullSizeContentViewWindowMask;
    
    [self.window center];
    
    NSRect frame = self.window.frame;
    frame.size.width = 900;
    frame.size.height = 700;
    
    [self.window setFrame:frame display:NO];
}

@end
