/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Cocoa/Cocoa.h>
#import "SubscriptionsDelegate.h"

@interface CustomRSSController : NSWindowController
{
    BOOL isTranslated;
    NSManagedObject *selectedShow;
    
    IBOutlet SubscriptionsDelegate *subscriptionsDelegate;
    
    IBOutlet NSWindow *CustomRSSWindow;
    
    IBOutlet NSTextField *rssSectionTitle;
    IBOutlet NSTextField *filterSectionTitle;
    IBOutlet NSTextField *nameText;
    IBOutlet NSTextField *feedText;
    IBOutlet NSTextField *tvdbText;
    IBOutlet NSComboBox *nameValue;
    IBOutlet NSTableView *feedsValue;
    IBOutlet NSButton *addFeedButton;
    IBOutlet NSButton *removeFeedButton;
    IBOutlet NSTextField *tvdbValue;
    IBOutlet NSButton *showQuality;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSButton *subscribeButton;
    IBOutlet NSTableColumn *colHD;
    IBOutlet NSTableColumn *colName;
    IBOutlet NSTableColumn *colSeason;
    IBOutlet NSTableColumn *colEpisode;
    IBOutlet NSTableColumn *colDate;
    
    IBOutlet NSArrayController *SBArrayController;
    IBOutlet NSArrayController *episodeArrayController;
    IBOutlet NSArrayController *feedArrayController;
    IBOutlet NSTableView *episodeTableView;
    IBOutlet NSPredicateEditor *filtersEditor;
    
    IBOutlet NSPredicate *filterRules;
}

@property (retain) NSManagedObject *selectedShow;

- (IBAction) displayCustomRSSWindow:(id)sender;
- (IBAction) displayEditWindow:(id)sender;
- (IBAction) addFeed:(id)sender;
- (IBAction) removeFeed:(id)sender;
- (void) setEpisodesFromRSS:(NSArray *)feeds;
- (void) updateEpisodes:(NSArray *)data;
- (void) resetShowView;
- (void) setUserDefinedShowQuality;
- (IBAction) showQualityDidChange:(id)sender;
- (void) setPossibleNamesFromFeed;
- (IBAction) closeCustomRSSWindow:(id)sender;

#pragma mark -
#pragma mark Subscription Methods
- (IBAction) subscribeToShow:(id)sender;

@end
