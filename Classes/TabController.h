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

#import <PreferencePanes/PreferencePanes.h>
#import <Cocoa/Cocoa.h>
#import "SubscriptionsDelegate.h"
#import "LRFilterBar.h"
#import <Sparkle/SUUpdater.h>

@interface TabController : NSPreferencePane
{
    IBOutlet NSTabView *prefTabView;
    IBOutlet NSButton *feedbackButton;
    NSManagedObject *selectedShow;
    
    IBOutlet SubscriptionsDelegate *subscriptionsDelegate;
    
    // Version information
    IBOutlet NSTextField *sidebarHeader;
    IBOutlet NSTextField *sidebarVersionText;
    IBOutlet NSTextField *sidebarDateText;
    
    // About tab
    IBOutlet NSTextView *textView_aboutBox;
    IBOutlet NSButton *websiteButton;
    IBOutlet NSButton *donateButton;
    IBOutlet NSButton *resetWarningsButton;
    IBOutlet NSButton *viewLogsButton;
    IBOutlet NSButton *uninstallButton;
    IBOutlet NSTextField *disclaimer;
    
    // Log Viewer
    IBOutlet NSTextView *textView_logViewer;
    IBOutlet NSWindow *logViewerWindow;
    IBOutlet NSTextField *logTitleText;
    IBOutlet NSTextField *logExplanationText;
    IBOutlet NSTextField *logLocalizationText;
    IBOutlet NSButton *closeLogButton;
    
    // Subscriptions tab
    IBOutlet LRFilterBar *filterBar;
    IBOutlet NSSearchField *filterField;
    IBOutlet NSArrayController *SBArrayController;
    IBOutlet NSWindow *showInfoWindow;
    IBOutlet NSTextField *lastCheckedText;
    IBOutlet NSButton *addButton;
    IBOutlet NSButton *addRSSButton;
    IBOutlet NSTextField *lastCheckedDate;
    IBOutlet NSTextField *endedRibbonText;
    IBOutlet NSImageView *noSubscriptionsArrow;
    IBOutlet NSTableColumn *colHD;
    IBOutlet NSTableColumn *colName;
    IBOutlet NSTableColumn *colSeason;
    IBOutlet NSTableColumn *colEpisode;
    IBOutlet NSTableColumn *colDate;
    
    // Show info window
    IBOutlet NSTextField *showName;
    IBOutlet NSTextField *showStatus;
    IBOutlet NSTextField *showLastDownloaded;
    IBOutlet NSTextField *showNextEpisode;
    IBOutlet NSButton *showQuality;
    IBOutlet NSButton *showIsEnabled;
    IBOutlet NSArrayController *episodeArrayController;
    IBOutlet NSTableView *episodeTableView;
    IBOutlet NSTextField *statusTitle;
    IBOutlet NSTextField *lastDownloadedTitle;
    IBOutlet NSTextField *nextEpisodeTitle;
    IBOutlet NSBox *infoBoxTitle;
    IBOutlet NSBox *prefBoxTitle;
    IBOutlet NSButton *closeButton;
    IBOutlet NSButton *editButton;
    IBOutlet NSButton *unsubscribeButton;
    IBOutlet NSImageView *showPoster;
}

@property (retain) NSManagedObject *selectedShow;

- (void) awakeFromNib;
- (void) showArrowIfNeeded:(id)sender;
- (IBAction) filterSubscriptions:(id)sender;
- (void) resetFilters;
- (void) refreshShowList:(NSNotification *)inNotification;
- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
- (IBAction) showFeedbackWindow:(id)sender;

#pragma mark -
#pragma mark About Tab
- (IBAction) openWebsite:(id)sender;
- (IBAction) openBlog:(id)sender;
- (IBAction) openTwitter:(id)sender;
- (IBAction) openPaypal:(id)sender;
- (IBAction) resetWarnings:(id)sender;
- (IBAction) openUninstaller:(id)sender;
- (void) drawAboutBox;

#pragma mark -
#pragma mark Log Viewer
- (IBAction) showLogViewerWindow:(id)sender;
- (IBAction) closeLogViewerWindow:(id)sender;

#pragma mark -
#pragma mark Subscriptions TabController
- (IBAction) displayShowInfoWindow:(id)sender;
- (void) setEpisodesForShow:(NSString *)showFeeds;
- (void) setStatusForShow:(NSArray *)arguments;
- (void) setNextEpisodeForShow:(NSArray *)arguments;
- (void) setPosterForShow:(NSArray *)arguments;
- (void) updateEpisodes:(NSArray *)data;
- (void) updateStatus:(NSArray *)data;
- (void) updateNextEpisode:(NSArray *)data;
- (void) updatePoster:(NSArray *)data;
- (IBAction) refreshPoster:(id)sender;
- (IBAction) closeShowInfoWindow:(id)sender;
- (IBAction) showQualityDidChange:(id)sender;
- (void) sortSubscriptionList;
- (IBAction) unsubscribeFromShow:(id)sender;
- (BOOL) shouldUnsubscribeFromShow;

- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile;

@end
