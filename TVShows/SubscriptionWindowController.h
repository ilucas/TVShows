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

@import Cocoa;
@import Quartz;
@import MagicalRecord;

@class TVDBSerie;
@class TVDBEpisode;
@class MetadataViewController;

@interface SubscriptionWindowController : NSWindowController <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>

#pragma mark - Show info
@property (weak) IBOutlet MetadataViewController *metadataViewController;

#pragma mark - Settings
@property (weak) IBOutlet NSPopUpButton *showQuality;
@property (weak) IBOutlet NSButton *subscribeButton;

#pragma mark - Show list
@property (weak, nonatomic) IBOutlet NSTableView *showsTableView;
@property (weak, nonatomic) IBOutlet NSSearchField *searchField;
@property (strong, strong, nonatomic) NSMutableArray <TVDBSerie *> *showList;

#pragma mark - Episodes List
@property (weak) IBOutlet NSTableView *episodesTableView;
@property (weak, nonatomic) IBOutlet NSArrayController *episodesArrayController;
@property (strong, nonatomic) NSMutableArray <TVDBEpisode *> *episodesList;

#pragma mark - Actions
- (IBAction)openMoreInfoURL:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)subscribeToShow:(id)sender;
- (IBAction)selectNextAired:(id)sender;
- (IBAction)selectOtherEpisode:(id)sender;
- (IBAction)search:(id)sender;

@end
