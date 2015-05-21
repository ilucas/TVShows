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

@interface SubscriptionWindowController : NSWindowController <NSTableViewDelegate>

#pragma mark - Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Show info
@property (weak) IBOutlet NSBox *metadataBox;
@property (weak) IBOutlet NSImageView *showPoster;
@property (weak) IBOutlet NSTextField *showName;
@property (weak) IBOutlet NSTextField *showYear;
@property (weak) IBOutlet NSTextField *showDuration;
@property (weak) IBOutlet NSLevelIndicator *rating;
@property (weak) IBOutlet NSTextField *genre;
@property (unsafe_unretained) IBOutlet NSTextView *showDescription;
@property (weak) IBOutlet NSImageView *studioLogo;

@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSTextField *loadingText;

#pragma mark - Settings
@property (weak) IBOutlet NSPopUpButton *showQuality;
@property (weak) IBOutlet NSTableView *episodesTableView;

#pragma mark - Show list
@property (weak, nonatomic) IBOutlet NSTableView *showsTableView;
@property (strong, nonatomic) IBOutlet NSArrayController *showsArrayController;
@property (weak, nonatomic) IBOutlet NSSearchField *SearchField;

#pragma mark - Actions
- (IBAction)reloadShowList:(id)sender;
- (IBAction)openMoreInfoURL:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)subscribeToShow:(id)sender;

@end
