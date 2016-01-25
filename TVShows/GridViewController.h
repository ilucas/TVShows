//
//  GridViewController.h
//  TVShows
//
//  Created by Lucas Casteletti on 1/24/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

@import Cocoa;
@import Quartz;

@class OEGridView;

@interface GridViewController : NSViewController

@property (weak) IBOutlet OEGridView *gridView;

- (void)reloadData;

@end
