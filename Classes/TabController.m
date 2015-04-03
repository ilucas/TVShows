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

#import <QuartzCore/QuartzCore.h>

#import "AppInfoConstants.h"
#import "TabController.h"

#import "TSParseXMLFeeds.h"
#import "TSUserDefaults.h"
#import "TSRegexFun.h"
#import "TSTorrentFunctions.h"

#import "TorrentzParser.h"
#import "TheTVDB.h"
#import "LCLLogFile.h"
#import "WebsiteFunctions.h"

#ifndef NSAppKitVersionNumber10_5
#define NSAppKitVersionNumber10_5   949
#endif

#ifndef NSAppKitVersionNumber10_6
#define NSAppKitVersionNumber10_6 1038
#endif

#ifndef NSAppKitVersionNumber10_7
#define NSAppKitVersionNumber10_7 1115
#endif

#ifndef NSAppKitVersionNumber10_8
#define NSAppKitVersionNumber10_8 1162
#endif

@implementation TabController

@synthesize selectedShow;

- (void) awakeFromNib {
    // Avoid this on Leopard
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5) {
        // Register the app for this notification
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(refreshShowList:)
                                                                name:@"TSUpdatedShows"
                                                              object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshShowList:)
                                                     name:@"TSUpdatedShows"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshShowList:)
                                                     name:@"TSAddSubscription"
                                                   object:nil];
    }
    
    // Filter bar
    [filterBar addItemsWithTitles:[NSArray arrayWithObjects:
                                   TSLocalizeString(@"All"),
                                   TSLocalizeString(@"Enabled"),
                                   TSLocalizeString(@"Disabled"),
                                   @"DIVIDER",
                                   TSLocalizeString(@"All"),
                                   TSLocalizeString(@"Preset"),
                                   TSLocalizeString(@"Custom"), nil]
                     withSelector:@selector(filterSubscriptions:)
                       withTarget:self];
    
    // Set displayed version information
    NSString *bundleVersion = [[[NSBundle bundleWithIdentifier: TVShowsAppDomain] infoDictionary] 
                               valueForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[[NSBundle bundleWithIdentifier: TVShowsAppDomain] infoDictionary]
                              valueForKey:@"CFBundleVersion"];
    NSString *buildDate = [[[NSBundle bundleWithIdentifier: TVShowsAppDomain] infoDictionary]
                           valueForKey:@"TSBundleBuildDate"];
    
    [sidebarHeader setStringValue:@"TVShows 2"];
    [sidebarVersionText setStringValue: [NSString stringWithFormat:@"%@ (r%@)", bundleVersion, buildVersion]];
    [sidebarDateText setStringValue:buildDate];
    [endedRibbonText setStringValue:[TSLocalizeString(@"Ended") uppercaseString]];
    
    [self fixEndedRibbonText];
    
    NSDate *date = [TSUserDefaults getDateFromKey:@"lastCheckedForEpisodes"];
    if (date) {
        // Set the last date/time episodes were checked for.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        [lastCheckedDate setStringValue: [[[dateFormatter stringFromDate: date] stringByAppendingString:TSLocalizeString(@" at ")]
                                          stringByAppendingString: [timeFormatter stringFromDate: date]]];
    } else {
        [lastCheckedDate setStringValue: TSLocalizeString(@"Never")];
    }
    
    // Localize everything
    [[prefTabView tabViewItemAtIndex:0] setLabel: TSLocalizeString(@"Subscriptions")];
    [[prefTabView tabViewItemAtIndex:1] setLabel: TSLocalizeString(@"Preferences")];
    [[prefTabView tabViewItemAtIndex:2] setLabel: TSLocalizeString(@"About")];
    
    [feedbackButton setTitle: TSLocalizeString(@"Submit Feedback")];
    
    [addButton setTitle: TSLocalizeString(@"Add Show")];
    [addRSSButton setTitle: TSLocalizeString(@"Add Custom RSS")];
    [lastCheckedText setStringValue: TSLocalizeString(@"Last Checked:")];
    
    [websiteButton setTitle: TSLocalizeString(@"Website")];
    [donateButton setTitle: TSLocalizeString(@"Donate")];
    [resetWarningsButton setTitle: TSLocalizeString(@"Reset Warn.")];
    [viewLogsButton setTitle: TSLocalizeString(@"View Logs")];
    [uninstallButton setTitle: TSLocalizeString(@"Uninstall")];
    [disclaimer setStringValue: TSLocalizeString(@"No actual videos are downloaded by TVShows, only torrents which will require other programs to use. It is up to you, the user, to decide the legality of using any of the files downloaded by this application, in accordance with applicable copyright laws of you country.")];
    
    [logTitleText setStringValue: TSLocalizeString(@"Recently Logged Activity")];
    [logExplanationText setStringValue: TSLocalizeString(@"A message is logged each time new episodes are checked for. Unless noted otherwise, no new episodes were found.")];
    [logLocalizationText setStringValue: TSLocalizeString(@"Logs are stored in ~/Library/Logs/TVShows/")];
    [closeLogButton setTitle: TSLocalizeString(@"Close")];
    
    // Localize the headings of the table columns
    [[colHD headerCell] setStringValue: TSLocalizeString(@"HD")];
    [[colName headerCell] setStringValue: TSLocalizeString(@"Episode Name")];
    [[colSeason headerCell] setStringValue: TSLocalizeString(@"Season")];
    [[colEpisode headerCell] setStringValue: TSLocalizeString(@"Episode")];
    [[colDate headerCell] setStringValue: TSLocalizeString(@"Published Date")];
    
    // Localize everything else
    [showQuality setTitle: TSLocalizeString(@"Download in HD")];
    [showIsEnabled setTitle: TSLocalizeString(@"Enable downloading new episodes")];
    [statusTitle setStringValue: TSLocalizeString(@"Status")];
    [lastDownloadedTitle setStringValue: TSLocalizeString(@"Last Downloaded")];
    [nextEpisodeTitle setStringValue: TSLocalizeString(@"Next Episode")];
    [infoBoxTitle setTitle: TSLocalizeString(@"Info")];
    [prefBoxTitle setTitle: TSLocalizeString(@"Preferences")];
    [closeButton setTitle: TSLocalizeString(@"Close")];
    [editButton setTitle: TSLocalizeString(@"Edit")];
    [unsubscribeButton setTitle: TSLocalizeString(@"Unsubscribe")];
    
    // Sort the subscription list and draw the About box
    [self sortSubscriptionList];
    [self drawAboutBox];
    
    // Add color to the donate button
    [self performSelector:@selector(colorDonateButton)];
    
    // Draw the arrow if the user does not have any shows
    [self performSelector:@selector(showArrowIfNeeded:) withObject:nil afterDelay:1];
}

- (void)fixEndedRibbonText {
    // Avoid this fix on Lion and before
    if (floor(NSAppKitVersionNumber) < NSAppKitVersionNumber10_8) {
        return;
    }
    
    CIFilter *affineTransform = [[endedRibbonText contentFilters] objectAtIndex:0];
    NSAffineTransform *inputTransform = [affineTransform valueForKey:@"inputTransform"];
    [inputTransform rotateByRadians:-M_PI/2.0];
    [inputTransform translateXBy:-16 yBy:-7.5];
    
    [affineTransform setValue:inputTransform forKey:@"inputTransform"];
    
    [endedRibbonText setContentFilters:[NSArray arrayWithObjects:affineTransform, nil]];
}

- (void) showArrowIfNeeded:(id)sender {
    if ([[SBArrayController content] count] == 0) {
        [noSubscriptionsArrow setHidden:NO];
    }
}

- (IBAction) filterSubscriptions:(id)sender {
    NSMutableArray *filters = [[NSMutableArray alloc] initWithCapacity:3];
    
    switch ([filterBar getSelectedIndexInSegment:0]) {
        case 1:
            [filters addObject:[NSPredicate predicateWithFormat:@"isEnabled = 1"]];
            break;
        case 2:
            [filters addObject:[NSPredicate predicateWithFormat:@"isEnabled = 0"]];
            break;
        default:
            break;
    }
    switch ([filterBar getSelectedIndexInSegment:1]) {
        case 1:
            [filters addObject:[NSPredicate predicateWithFormat:@"filters = nil"]];
            break;
        case 2:
            [filters addObject:[NSPredicate predicateWithFormat:@"filters != nil"]];
            break;
        default:
            break;
    }
    if ([[filterField stringValue] length] > 0) {
        [filters addObject:[NSPredicate predicateWithFormat:@"name contains[cd] %@", [filterField stringValue]]];
    }
    [SBArrayController setFilterPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:filters]];
}

- (void) resetFilters {
    [filterBar selectIndex:0 inSegment:0];
    [filterBar selectIndex:0 inSegment:1];
    [filterField setStringValue:@""];
}

- (void) refreshShowList:(NSNotification *)inNotification {
    [subscriptionsDelegate refresh];
    [SBArrayController setManagedObjectContext:[subscriptionsDelegate managedObjectContext]];
    [SBArrayController fetch:nil];
    [SBArrayController rearrangeObjects];
    [self resetFilters];
}

- (void) colorDonateButton {
    // Get the content filters for the button (there are two, one to add color and another one to change the hue)
    CIFilter *colorAdjust = [[donateButton contentFilters] objectAtIndex:0];
    
    // Randomly select a hue (in radians, max is 2*PI because it is a circle)
    double hue = ((double) arc4random() / RAND_MAX) * (2 * M_PI);
    
    CIFilter *hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
    [hueAdjust setDefaults];
    [hueAdjust setValue:[NSNumber numberWithDouble:hue] forKey:@"inputAngle"];
    
    [donateButton setContentFilters:[NSArray arrayWithObjects:colorAdjust, hueAdjust, nil]];
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSRect tabFrame;
    int newWinHeight;
    
    tabFrame = [[tabView window] frame];
    
    // newWinHeight should be equal to the wanted window size (in Interface Builder) + 54 (title bar height)
    if ([[tabViewItem identifier] isEqualTo:@"tabItemSubscriptions"]) {
        newWinHeight = 597;
    } else if ([[tabViewItem identifier] isEqualTo:@"tabItemSync"]) {
        newWinHeight = 396;
    } else if ([[tabViewItem identifier] isEqualTo:@"tabItemPreferences"]) {
        newWinHeight = 698;
    }  else if ([[tabViewItem identifier] isEqualTo:@"tabItemAbout"]) {
        newWinHeight = 500;
    } else {
        newWinHeight = 610;
    }
    
    tabFrame = NSMakeRect(tabFrame.origin.x, tabFrame.origin.y - (newWinHeight - (int)(NSHeight(tabFrame))), (int)(NSWidth(tabFrame)), newWinHeight);
    
    [[tabView window] setFrame:tabFrame display:YES animate:YES];
}

- (IBAction) showFeedbackWindow:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: TVShowsSupport]];
}

#pragma mark -
#pragma mark About Tab
- (IBAction) openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: TVShowsWebsite]];
}

- (IBAction) openBlog:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: TVShowsBlog]];
}

- (IBAction) openTwitter:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: TVShowsTwitter]];
}

- (IBAction) openPaypal:(id)sender {
    // This is a list of accepted currencies for Paypal transfers and donations
    NSArray *acceptedCurrencies = [NSArray arrayWithObjects:@"AUD", @"BRL", @"CAD", @"CZK", @"DKK", @"EUR",
                                   @"HKD", @"HUF", @"ILS", @"JPY", @"MXN", @"NOK", @"NZD", @"PHP", @"PLN",
                                   @"GBP", @"SGD", @"SEK", @"CHF", @"TWD", @"THB", @"TRY", @"USD", nil];
    
    // And this should be the preferred currency for this user
    NSString *currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    
    // Let's assume is not supported
    BOOL supported = NO;
    
    // And let's see if it is in that currency list
    for (NSString *code in acceptedCurrencies) {
        if ([currencyCode isEqualToString:code]) {
            supported = YES;
            break;
        }
    }
    
    // Fallback to euros!
    if (!supported) {
        currencyCode = @"EUR";
    }
    
    // Also retrieve the country for this user
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    NSString *donationURL = [NSString stringWithFormat:TVShowsDonations, currencyCode, countryCode];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:donationURL]];
}

- (IBAction) resetWarnings:(id)sender {
    // Set all keys to "please asks me"
    [TSUserDefaults setKey:@"AutoDownloadFallbackSD" fromInt:ShowWarning];
    [TSUserDefaults setKey:@"AutoDeleteSubscription" fromInt:ShowWarning];
    
    // Alert the user that the operation was done
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: TSLocalizeString(@"Ok")];
    [alert setMessageText: TSLocalizeString(@"Warnings restored")];
    [alert setInformativeText: TSLocalizeString(@"Your preferences about warnings were restored. If needed, next time TVShows will ask for your confirmation to complete a sensitive operation.")];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
}

- (IBAction) openUninstaller:(id)sender {
    // Create an alert box.
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle: TSLocalizeString(@"Yes")];
    [alert addButtonWithTitle: TSLocalizeString(@"No")];
    [alert setMessageText: TSLocalizeString(@"Uninstall TVShows")];
    [alert setInformativeText: TSLocalizeString(@"Are you sure you want to uninstall TVShows? This will also remove all preferences and subscriptions.")];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    // Run the alert and then wait for user input.
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        // Drat! They really do want to uninstall. Find the path to the uninstaller.
        NSString *launchPath = [[NSBundle bundleWithIdentifier: TVShowsAppDomain]
                                pathForResource:@"Uninstaller"
                                ofType:@"app"];
        launchPath = [launchPath stringByAppendingPathComponent:@"Contents/MacOS/applet"];
        
        // Start up an NSTask to run the uninstaller.
        NSTask *uninstaller = [[NSTask alloc] init];
        [uninstaller setLaunchPath:launchPath];
        [uninstaller launch];
    }
}

- (void) drawAboutBox {
    NSString *pathToAboutBoxText = [[NSBundle bundleWithIdentifier: TVShowsAppDomain] 
                                    pathForResource: @"Credits" 
                                    ofType: @"rtf"];
    
    NSAttributedString *aboutBoxText = [[NSAttributedString alloc]
                                         initWithPath: pathToAboutBoxText
                                         documentAttributes: nil];
    
    [[textView_aboutBox textStorage] setAttributedString:aboutBoxText];
}

#pragma mark -
#pragma mark Log Viewer

- (IBAction) showLogViewerWindow:(id)sender {
    NSString *loggedItems;
    
    [NSApp beginSheet: logViewerWindow
       modalForWindow: [[NSApplication sharedApplication] mainWindow]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    loggedItems = [NSString stringWithContentsOfFile: [LCLLogFile defaultPathInHomeLibraryLogsOrPath:nil]
                                            encoding: NSUTF8StringEncoding
                                               error: NULL];
    
    if (!loggedItems) {
        loggedItems = TSLocalizeString(@"No activity has been logged yet. Have you recently installed TVShows?");
    }
    
    [textView_logViewer setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
    [textView_logViewer setString:loggedItems];
    [textView_logViewer moveToEndOfDocument:nil];
    
    [NSApp endSheet: logViewerWindow];
    [NSApp runModalForWindow: logViewerWindow];
}

- (IBAction) closeLogViewerWindow:(id)sender {
    [NSApp stopModal];
    [logViewerWindow orderOut: self];
}

#pragma mark -
#pragma mark Subscriptions Tab
- (IBAction) displayShowInfoWindow:(id)sender {
    selectedShow = [[[sender cell] representedObject] representedObject];
    
    // Link that info to the edit button
    [[editButton cell] setRepresentedObject:self];
    
    // Set up the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Set the available values now
    [showName setStringValue: [selectedShow valueForKey:@"name"]];
    [showStatus setStringValue: TSLocalizeString(@"Unknown")];
    [showLastDownloaded setStringValue: [dateFormatter stringFromDate:[selectedShow valueForKey:@"lastDownloaded"]]];
    [showNextEpisode setStringValue: TSLocalizeString(@"Unknown")];
    [showQuality setState: [[selectedShow valueForKey:@"quality"] intValue]];
    [showIsEnabled setState: [[selectedShow valueForKey:@"isEnabled"] boolValue]];
    
    NSImage *defaultPoster = [[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"posterArtPlaceholder" ofType:@"jpg"]];
    [defaultPoster setSize: NSMakeSize(127, 184)];
    [showPoster setImage: defaultPoster];
    
    // Reset the Episode Array Controller
    [[episodeArrayController content] removeAllObjects];
    [episodeArrayController removeObjects:[episodeArrayController arrangedObjects]];
    [episodeTableView reloadData];
    [episodeTableView setEnabled:NO];
    
    if (selectedShow) {
        NSString *showFeeds = [selectedShow valueForKey:@"url"];
        NSArray *arguments = [NSArray arrayWithObjects:[selectedShow valueForKey:@"name"],
                              [NSString stringWithFormat:@"%@", [selectedShow valueForKey:@"tvdbID"]], nil];
        
        // Grab the list of episodes
        [self performSelectorInBackground:@selector(setEpisodesForShow:) withObject:showFeeds];
        
        // Display the show poster now that it's been resized.
        [self performSelectorInBackground:@selector(setPosterForShow:) withObject:arguments];
        
        // Grab the show status
        [self performSelectorInBackground:@selector(setStatusForShow:) withObject:arguments];
        
        // Grab the next episode date
        [self performSelectorInBackground:@selector(setNextEpisodeForShow:) withObject:arguments];
    }
    
    [NSApp beginSheet: showInfoWindow
       modalForWindow: [[NSApplication sharedApplication] mainWindow]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp endSheet: showInfoWindow];
    [NSApp runModalForWindow: showInfoWindow];
}

#pragma mark -
#pragma mark Background workers
- (void) setEpisodesForShow:(NSString *)showFeeds {
    @autoreleasepool {
        NSMutableArray *feeds = [NSMutableArray arrayWithArray:[showFeeds componentsSeparatedByString:@"#"]];
        
        // Generate the full feeds for this suscription
        for (int i = 0; i < [feeds count]; i++) {
            NSString *feed = [TSRegexFun obtainFullFeed:[feeds objectAtIndex:i]];
            [feeds replaceObjectAtIndex:i
                             withObject:feed];
        }
        
        // Now we can trigger the time-expensive task
        NSArray *results = [NSArray arrayWithObjects:showFeeds,
                            [TSParseXMLFeeds parseEpisodesFromFeeds:feeds
                                                    beingCustomShow:([selectedShow valueForKey:@"filters"] != nil)], nil];
        
        if ([results count] < 2) {
            LogError(@"Could not download/parse feed(s) <%@>", showFeeds);
            return;
        }
        
        [self performSelectorOnMainThread:@selector(updateEpisodes:) withObject:results waitUntilDone:NO];
    }
}

- (void) setStatusForShow:(NSArray *)arguments {
    @autoreleasepool {
        // Now we can trigger the time-expensive task
        NSArray *results = [NSArray arrayWithObjects:[arguments objectAtIndex:0],
                            [TheTVDB getShowStatus:[arguments objectAtIndex:0]
                                        withShowID:[arguments objectAtIndex:1]], nil];
        
        [self performSelectorOnMainThread:@selector(updateStatus:) withObject:results waitUntilDone:NO];
    }
}

- (void) setNextEpisodeForShow:(NSArray *)arguments {
    @autoreleasepool {
        // Now we can trigger the time-expensive task
        NSArray *results = [NSArray arrayWithObjects:[arguments objectAtIndex:0],
                            [TheTVDB getShowNextEpisode:[arguments objectAtIndex:0]
                                             withShowID:[arguments objectAtIndex:1]], nil];
        
        [self performSelectorOnMainThread:@selector(updateNextEpisode:) withObject:results waitUntilDone:NO];
    }
}

- (void) setPosterForShow:(NSArray *)arguments
{
    @autoreleasepool {
        // Now we can trigger the time-expensive task
        NSArray *results = [NSArray arrayWithObjects:[arguments objectAtIndex:0],
                            [[TheTVDB getPosterForShow:[arguments objectAtIndex:0]
                                             withShowID:[arguments objectAtIndex:1]
                                             withHeight:187
                                              withWidth:129] copy], nil];
        
        [self performSelectorOnMainThread:@selector(updatePoster:) withObject:results waitUntilDone:NO];
    }
}

- (void) updateEpisodes:(NSArray *)data {
    // We are back after probably a lot of time, so check carefully if the user has changed the selection
    if (!selectedShow) {
        return;
    }
    
    // Extract the data
    NSString *showFeeds = [data objectAtIndex:0];
    NSArray *results = [data objectAtIndex:1];
    NSString *copy = [selectedShow valueForKey:@"url"];
    
    // Continue only if the selected show is the same as before
    if ([showFeeds isEqualToString:copy]) {
        [episodeTableView setEnabled:YES];
        [episodeArrayController addObjects:results];
        
        // Check if there are HD episodes, if so enable the "Download in HD" checkbox
//        BOOL feedHasHDEpisodes = [TSParseXMLFeeds feedHasHDEpisodes:results];
        
//        if (!feedHasHDEpisodes) {
//            [showQuality setState:NO];
//        }
//        [showQuality setEnabled:feedHasHDEpisodes];
        
        // Update the filter predicate to only display the correct quality.
        [self showQualityDidChange:nil];
    }
}

- (void) updateStatus:(NSArray *)data {
    // We are back after probably a lot of time, so check carefully if the user has changed the selection
    if (!selectedShow) {
        return;
    }
    
    // Extract the data
    NSString *name = [data objectAtIndex:0];
    NSString *status = nil;
    if ([data count] > 1) {
        status = [data objectAtIndex:1];
    }
    NSString *copy = [selectedShow valueForKey:@"name"];
    
    // Continue only if the selected show is the same as before
    if ([name isEqualToString:copy] && status != nil) {
        // And finally we can set the status
        [showStatus setStringValue:TSLocalizeString(status)];
        if ([status isEqualToString:@"Ended"]) {
            [showNextEpisode setStringValue:TSLocalizeString(@"Never")];
        }
    }
}

- (void) updateNextEpisode:(NSArray *)data {
    // We are back after probably a lot of time, so check carefully if the user has changed the selection
    if (!selectedShow) {
        return;
    }
    
    // Extract the data
    NSString *name = [data objectAtIndex:0];
    NSDate *nextEpisode = nil;
    if ([data count] > 1) {
        nextEpisode = [data objectAtIndex:1];
    }
    NSString *copy = [selectedShow valueForKey:@"name"];
    
    // Continue only if the selected show is the same as before
    if ([name isEqualToString:copy] && nextEpisode != nil) {
        // Set up the date formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        [showNextEpisode setStringValue:[dateFormatter stringFromDate:nextEpisode]];
    }
}

- (void) updatePoster:(NSArray *)data {
    // We are back after probably a lot of time, so check carefully if the user has changed the selection
    if (!selectedShow) {
        return;
    }
    
    // Extract the data
    NSString *name = [data objectAtIndex:0];
    NSImage *poster = [data objectAtIndex:1];
    NSString *copy = [selectedShow valueForKey:@"name"];
    
    // Continue only if the selected show is the same as before
    if ([name isEqualToString:copy]) {
        [showPoster setImage:poster];
        [showPoster display];
    }
}

- (IBAction) refreshPoster:(id)sender {
    // Remove poster from the cache to force the download
    [TheTVDB removePosterForShow:[selectedShow valueForKey:@"name"]];
    
    NSArray *arguments = [NSArray arrayWithObjects:[selectedShow valueForKey:@"name"],
                          [NSString stringWithFormat:@"%@", [selectedShow valueForKey:@"tvdbID"]], nil];
    
    // So download it
    [self performSelectorInBackground:@selector(setPosterForShow:) withObject:arguments];
}

- (IBAction) closeShowInfoWindow:(id)sender {
    // Close the window first
    [NSApp stopModal];
    [showInfoWindow orderOut: self];
    
    if (selectedShow != nil && [selectedShow respondsToSelector:@selector(objectID)]) {
        
        // Check if there are changes
        if (![[selectedShow valueForKey:@"quality"] isEqual:[NSNumber numberWithBool:[showQuality state]]] ||
            ![[selectedShow valueForKey:@"isEnabled"] isEqual:[NSNumber numberWithBool:[showIsEnabled state]]]) {
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[selectedShow objectID], @"showID",
                                      [NSNumber numberWithBool:[showQuality state]], @"quality",
                                      [NSNumber numberWithBool:[showIsEnabled state]], @"isEnabled", nil];
             
            // Notify the helper
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TSEditSubscription"
                                                                           object:nil
                                                                         userInfo:userInfo];
            
            // NSManagedContext objectWithID is required for it to save changes to the disk.
            // We also need to update the original selectedShow NSManagedObject so that the
            // interface displays any changes when the window is opened multiple times a session.
            NSManagedObject *selectedShowObj = [[subscriptionsDelegate managedObjectContext] objectWithID:[selectedShow objectID]];
            // Refresh the show from the subscriptions (it may have changed)
            [[subscriptionsDelegate managedObjectContext] refreshObject:selectedShowObj mergeChanges:YES];
            
            // Update the per-show preferences
            [selectedShow setValue:[NSNumber numberWithInt:[showQuality state]] forKey:@"quality"];
            [selectedShow setValue:[NSNumber numberWithBool:[showIsEnabled state]] forKey:@"isEnabled"];
            [selectedShowObj setValue:[NSNumber numberWithInt:[showQuality state]] forKey:@"quality"];
            [selectedShowObj setValue:[NSNumber numberWithBool:[showIsEnabled state]] forKey:@"isEnabled"];
            
            // Be sure to process pending changes before saving or it won't save correctly.
            [[subscriptionsDelegate managedObjectContext] processPendingChanges];
            [subscriptionsDelegate saveAction];
            
            [self filterSubscriptions:nil];
        }
        
        // Reset the selected show
        selectedShow = nil;
    }
}

- (IBAction) showQualityDidChange:(id)sender {
    if ([showQuality state]) {
        [episodeArrayController setFilterPredicate:
         [NSCompoundPredicate andPredicateWithSubpredicates:
          [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"isHD == '1'"],
           [selectedShow valueForKey:@"filters"],nil]]];
    } else {
        [episodeArrayController setFilterPredicate:
         [NSCompoundPredicate andPredicateWithSubpredicates:
          [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"isHD == '0'"],
           [selectedShow valueForKey:@"filters"],nil]]];
    }
}

- (BOOL) tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    // Check to see whether or not this is the GET button or not.
    
    // Which column and row was clicked?
    NSInteger clickedCol = [episodeTableView clickedColumn];
    NSInteger clickedRow = [episodeTableView clickedRow];
    
    if (clickedRow >= 0 && clickedCol >= 0) {
        // Grab information about the clicked cell.
        NSCell *cell = [episodeTableView preparedCellAtColumn:clickedCol row:clickedRow];
        
        // If the cell is an NSButtonCell and it's enabled...
        if ([cell isKindOfClass:[NSButtonCell class]] && [cell isEnabled]) {
            // This currently only returns a Torrent file and should eventually regex
            // out the actual file extension of the item we're downloading.
            NSObject *episode = [[episodeArrayController arrangedObjects] objectAtIndex:clickedRow];
            
            // If correctly download, check-in on Miso
            if ([TSTorrentFunctions downloadEpisode:episode ofShow:selectedShow]) {
                // Notify to the process that a download was done (to check-in in Miso)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TSDownloadEpisode"
                                                                    object:nil
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                            [episode valueForKey:@"episodeName"],
                                                                            @"episodeName",
                                                                            [selectedShow valueForKey:@"name"],
                                                                            @"showName", nil]];
            } else {
                // Display the error
                NSRunCriticalAlertPanel([NSString stringWithFormat:TSLocalizeString(@"Unable to download %@"),
                                         [episode valueForKey:@"episodeName"]],
                                        TSLocalizeString(@"Cannot connect. Please try again later or check your internet connection"),
                                        TSLocalizeString(@"Ok"),
                                        nil,
                                        nil);
            }
        }
    }

    // Don't select the row
    return NO;
}

- (void) sortSubscriptionList {
    // Arguably, I don't really know how this works, and I only reached this method
    // after hours and hours of debugging and trying to make the NSArrayController not
    // send all its elements to the NSControllerView in every sorting step.
    // But OMG, THIS IS THE MOST AMAZING THING IN THE WORLD
    // IT'S SO GOOD I WANT TO HAVE KIDS WITH IT,
    // KILL THEM AND THEN MAKE MORE KIDS
    [SBArrayController setUsesLazyFetching:YES];
    
    NSSortDescriptor *SBSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"sortName"
                                                                     ascending: YES
                                                                      selector: @selector(caseInsensitiveCompare:)];
    [SBArrayController setSortDescriptors:[NSArray arrayWithObject:SBSortDescriptor]];
}

- (IBAction) unsubscribeFromShow:(id)sender {
    // Ask for confirmation to the user
    if (![self shouldUnsubscribeFromShow]) {
        return;
    }
    
    // Notify the helper
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[selectedShow objectID], @"showID", nil];
//    
//    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TSRemoveSubscription"
//                                                                   object:nil
//                                                                 userInfo:userInfo];
    
    // And update our "copy"
    NSManagedObject *selectedShowObj = [[subscriptionsDelegate managedObjectContext] objectWithID:[selectedShow objectID]];
    // Refresh the show from the subscriptions (it may have changed)
    [[subscriptionsDelegate managedObjectContext] refreshObject:selectedShowObj mergeChanges:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSRemoveSubscription"
                                                        object:nil
                                                      userInfo:(NSDictionary *)selectedShow];
    
    [[subscriptionsDelegate managedObjectContext] deleteObject:selectedShowObj];
    
    // Be sure to process pending changes before saving or it won't save correctly
    [[subscriptionsDelegate managedObjectContext] processPendingChanges];
    [subscriptionsDelegate saveAction];
    
    selectedShow = nil;
    
    [self resetFilters];
    
    [self closeShowInfoWindow:(id)sender];
}

- (BOOL) shouldUnsubscribeFromShow {
    // Get the user default. If there is no preference, use a "third" value
    BOOL shouldDownloadSD = [TSUserDefaults getFloatFromKey:@"AutoDeleteSubscription" withDefault:ShowWarning];
    
    // Display the warning if the user did not want to hide it
    if (shouldDownloadSD == ShowWarning) {
        // Display the warning
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:TSLocalizeString(@"Unsubscribe")];
        [alert addButtonWithTitle:TSLocalizeString(@"Cancel")];
        [alert setShowsSuppressionButton:YES];
        [alert setMessageText:[NSString stringWithFormat:
                               TSLocalizeString(@"Are you sure you want to unsubscribe from %@?"),
                               [selectedShow valueForKey:@"name"]]];
        [alert setInformativeText:TSLocalizeString(@"This action cannot be undone.")];
        [alert setAlertStyle:NSCriticalAlertStyle];
        
        // Run the alert and then wait for user input.
        shouldDownloadSD = ([alert runModal] == NSAlertFirstButtonReturn);
        
        // Remember the selected option for next time if the user wants to hide the warning
        if ([[alert suppressionButton] state]) {
            [TSUserDefaults setKey:@"AutoDeleteSubscription" fromInt:YES];
        }
    }
    
    return shouldDownloadSD;
}

- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile {
    
    NSDictionary *iconDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"menubar", @"key",
                              ([TSUserDefaults getBoolFromKey:@"ShowMenuBarIcon" withDefault:YES] ? @"Yes" : @"No" ), @"value",
                              @"Show the menubar icon", @"displayKey",
                              ([TSUserDefaults getBoolFromKey:@"ShowMenuBarIcon" withDefault:YES] ? @"Yes" : @"No" ), @"displayValue",
                              nil];
    
    NSDictionary *hdDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"hd", @"key",
                            ([TSUserDefaults getBoolFromKey:@"AutoSelectHDVersion" withDefault:NO] ? @"Yes" : @"No" ), @"value",
                            @"Select HD by default", @"displayKey",
                            ([TSUserDefaults getBoolFromKey:@"AutoSelectHDVersion" withDefault:NO] ? @"Yes" : @"No" ), @"displayValue",
                            nil];
    
    NSDictionary *additionalDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"additional", @"key",
                                    ([TSUserDefaults getBoolFromKey:@"UseAdditionalSourcesHD" withDefault:YES] ? @"Yes" : @"No" ), @"value",
                                    @"Use additional sources for HD", @"displayKey",
                                    ([TSUserDefaults getBoolFromKey:@"UseAdditionalSourcesHD" withDefault:YES] ? @"Yes" : @"No" ), @"displayValue",
                                    nil];
    
    NSDictionary *magnetsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"magnets", @"key",
                                 ([TSUserDefaults getBoolFromKey:@"PreferMagnets" withDefault:NO] ? @"Yes" : @"No" ), @"value",
                                 @"Use magnets", @"displayKey",
                                 ([TSUserDefaults getBoolFromKey:@"PreferMagnets" withDefault:NO] ? @"Yes" : @"No" ), @"displayValue",
                                 nil];
    
    NSDictionary *misoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"miso", @"key",
                              ([TSUserDefaults getBoolFromKey:@"MisoEnabled" withDefault:NO] ? @"Yes" : @"No" ), @"value",
                              @"Enable Miso", @"displayKey",
                              ([TSUserDefaults getBoolFromKey:@"MisoEnabled" withDefault:NO] ? @"Yes" : @"No" ), @"displayValue",
                              nil];
    
    NSDictionary *delayDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"delay", @"key",
                               [NSString stringWithFormat:@"%d", (int) [TSUserDefaults getFloatFromKey:@"checkDelay" withDefault:1]], @"value",
                               @"Check interval for episodes", @"displayKey",
                               @"2 hours", @"displayValue",
                               nil];
    
    // Fetch subscriptions
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription"
                                              inManagedObjectContext:[subscriptionsDelegate managedObjectContext]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *subscriptions = [[subscriptionsDelegate managedObjectContext] executeFetchRequest:request error:&error];
    
    int subscriptionsCount = [subscriptions count];
    
    NSDictionary *subsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"subscount", @"key",
                              [NSString stringWithFormat:@"%d", subscriptionsCount], @"value",
                              @"Number of subscriptions", @"displayKey",
                              [NSString stringWithFormat:@"%d subscriptions", subscriptionsCount], @"displayValue",
                              nil];
    
    NSArray *feedParams = [NSArray arrayWithObjects:iconDict, hdDict, additionalDict, magnetsDict, misoDict, delayDict, subsDict, nil];
    return feedParams;
}

@end
