//
//  MainWindowController.h
//  TVShows
//
//  Created by Lucas Casteletti on 1/23/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

@import Cocoa;

@interface MainWindowController : NSWindowController <NSWindowDelegate>

@property (weak) IBOutlet NSToolbar *toolBar;

- (IBAction)addAction:(id)sender;

@end
