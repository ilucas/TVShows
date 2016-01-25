//
//  MainWindowController.m
//  TVShows
//
//  Created by Lucas casteletti on 1/23/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

#import "MainWindowController.h"
#import "SubscriptionWindowController.h"
#import "GridViewController.h"

@interface MainWindowController ()

@property (nonatomic, strong) SubscriptionWindowController *subscriptionWindow;

@end

@implementation MainWindowController

#pragma mark - Lifecycle

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setUpWindow];
    
    self.subscriptionWindow = [[SubscriptionWindowController alloc] init];
}

#pragma mark - Override

- (IBAction)showWindow:(nullable id)sender {
    [super showWindow:sender];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    
}

// Notifies the delegate that the window is about to open a sheet.
- (void)windowWillBeginSheet:(NSNotification *)notification {

}

// Tells the delegate that the window has closed a sheet.
- (void)windowDidEndSheet:(NSNotification *)notification {
    GridViewController __weak *gridView = (GridViewController *)[self contentViewController];
    [gridView reloadData];
}

#pragma mark - IBAction

- (IBAction)addAction:(id)sender {
    [self.window beginSheet:self.subscriptionWindow.window completionHandler:nil];
}

#pragma mark - Private

- (void)setUpWindow {
    self.window.titleVisibility = NSWindowTitleHidden;
    
    NSRect frame = self.window.frame;
    frame.size.width = 700;
    frame.size.height = 500;
    
    [self.window setFrame:frame display:NO];
    
//    self.window.titlebarAppearsTransparent  = YES;
//    self.window.movableByWindowBackground = YES;
//    self.window.backgroundColor = [NSColor colorWithCalibratedWhite:0.11 alpha:1.0];
//    self.window.styleMask |= NSFullSizeContentViewWindowMask;
}

@end
