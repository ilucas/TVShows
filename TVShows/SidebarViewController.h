//
//  SidebarViewController.h
//  TVShows
//
//  Created by Lucas on 14/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Cocoa;

@interface SidebarViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;

@end
