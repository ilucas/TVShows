//
//  SubscriptionWindowController.h
//  TVShows
//
//  Created by Lucas on 02/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Cocoa;
@import Quartz;
@import MagicalRecord;

@class MetadataViewController;

@interface SubscriptionWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

#pragma mark - Show info
@property (weak) IBOutlet MetadataViewController *metadataViewController;

#pragma mark - Settings
@property (weak) IBOutlet NSPopUpButton *showQuality;
@property (weak) IBOutlet NSButton *subscribeButton;

#pragma mark - Show list
@property (weak, nonatomic) IBOutlet NSTableView *showsTableView;
@property (weak, nonatomic) IBOutlet NSSearchField *searchField;
@property (readonly, strong, nonatomic) NSMutableArray *showList;

#pragma mark - Episodes List
@property (weak) IBOutlet NSTableView *episodesTableView;
@property (weak, nonatomic) IBOutlet NSArrayController *episodesArrayController;
@property (strong, nonatomic) NSMutableArray *episodesList;

#pragma mark - Actions
- (IBAction)openMoreInfoURL:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)subscribeToShow:(id)sender;
- (IBAction)selectNextAired:(id)sender;
- (IBAction)selectOtherEpisode:(id)sender;

@end
