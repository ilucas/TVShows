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

#import "AppInfoConstants.h"
#import "TVShowsHelper.h"
#import "PreferencesController.h"
#import "PresetTorrentsController.h"
#import "TorrentzParser.h"
#import "TSParseXMLFeeds.h"
#import "TSUserDefaults.h"
#import "SUUpdaterSubclass.h"
#import "RegexKitLite.h"
#import "TSRegexFun.h"
#import "TheTVDB.h"
#import "TSTorrentFunctions.h"

@implementation TVShowsHelper

@synthesize checkerLoop, TVShowsHelperIcon, subscriptionsDelegate, presetShowsDelegate;

- init {
    if((self = [super init])) {
        checkerThread = nil;
        checkerLoop = nil;
        manually = NO;
        
        NSMutableString *appPath = [NSMutableString stringWithString:[[NSBundle bundleForClass:[self class]] bundlePath] ];
        [appPath replaceOccurrencesOfString:@"TVShowsHelper.app"
                                 withString:@""
                                    options:0
                                      range:NSMakeRange(0, [appPath length])];
        
        TVShowsHelperIcon = [[NSData alloc] initWithContentsOfFile:
                             [appPath stringByAppendingPathComponent:@"TVShows-On-Large.icns"]];
        
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(awakeFromSleep)
                                                                   name:NSWorkspaceDidWakeNotification
                                                                 object:nil];
    }
    
    return self;
}

- (void) awakeFromNib {
    // This should never happen, but let's make sure TVShows is enabled before continuing.
    if ([TSUserDefaults getBoolFromKey:@"isEnabled" withDefault:YES]) {
        
        // Set up Growl notifications
        [GrowlApplicationBridge setGrowlDelegate:self];
        
        // Show the menu if the user wants
        if([TSUserDefaults getBoolFromKey:@"ShowMenuBarIcon" withDefault:YES]) {
            [self activateStatusMenu];
        }
        
        [self checkNow:nil];
        
        
    } else {
        // TVShows is not enabled.
        LogWarning(@"The TVShowsHelper was running even though TVShows is not enabled. Quitting.");
        [self quitHelper:nil];
    }
}

- (NSObject *)getShow:(NSString *)showId fromArray:(NSArray *)array {
    for (NSObject *show in array) {
        if ([[[show valueForKey:@"tvdbID"] description] isEqualToString:showId]) {
            return show;
        }
    }
    
    return nil;
}

- (NSObject *)getShow:(NSString *)showId withName:(NSString *)seriesName fromDictionary:(NSDictionary *)dict {
    for (NSObject *show in dict) {
        if ([[[[show valueForKey:@"media"] valueForKey:@"tvdb_id"] description] isEqualToString:showId] ||
            [[[[show valueForKey:@"media"] valueForKey:@"title"] description] isEqualToString:seriesName]) {
            return show;
        }
    }
    
    return nil;
}

- (NSTimeInterval) userDelay {
    NSInteger delay;
    NSTimeInterval seconds;
    delay = [TSUserDefaults getFloatFromKey:@"checkDelay" withDefault:1];
    
    switch (delay) {
        case 0:
            // 30 minutes
            seconds = 30*60;
            break;
        case 1:
            // 1 hour
            seconds = 1*60*60;
            break;
        case 2:
            // 3 hours
            seconds = 3*60*60;
            break;
        case 3:
            // 6 hours
            seconds = 6*60*60;
            break;
        case 4:
            // 12 hours
            seconds = 12*60*60;
            break;
        case 5:
            // 1 day
            seconds = 24*60*60;
            break;
        case 6:
            // 1 day, old value, needs to be reverted back to 5
            seconds = 24*60*60;
            [TSUserDefaults setKey:@"checkDelay" fromFloat:5];
            break;
        default:
            // 1 hour
            seconds = 1*60;
    }
    
    return seconds;
}

- (void) runLoop {
    @autoreleasepool {
        NSRunLoop* threadLoop = [NSRunLoop currentRunLoop];
        
        checkerLoop = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]
                                               interval:[self userDelay]
                                                 target:self
                                               selector:@selector(checkAllShows)
                                               userInfo:nil
                                                repeats:YES];
        
        [threadLoop addTimer:checkerLoop forMode:NSDefaultRunLoopMode];
        [threadLoop run];
    }
}

- (void) runLoopAfterAwake {
    @autoreleasepool {
        NSRunLoop* threadLoop = [NSRunLoop currentRunLoop];
        
        // Calculate how many seconds do we have to wait until the next check
        NSTimeInterval nextCheck = [self userDelay] - [[NSDate date] timeIntervalSinceDate:
                                                       [TSUserDefaults getDateFromKey:@"lastCheckedForEpisodes"]];
        
        // If the next should already be done, do it now
        if (nextCheck < 0.1) {
            // Wait a little for connecting to the network
            nextCheck = 60;
            // Notify the user to give him some feedback
            [GrowlApplicationBridge notifyWithTitle:@"TVShows"
                                        description:TSLocalizeString(@"Checking for new episodes...")
                                   notificationName:@"Checking For New Episodes"
                                           iconData:TVShowsHelperIcon
                                           priority:0
                                           isSticky:0
                                       clickContext:nil];
        }
        
        checkerLoop = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:nextCheck]
                                               interval:[self userDelay]
                                                 target:self
                                               selector:@selector(checkAllShows)
                                               userInfo:nil
                                                repeats:YES];
        
        [threadLoop addTimer:checkerLoop forMode:NSDefaultRunLoopMode];
        [threadLoop run];
    }
}

- (void) awakeFromSleep {
    LogInfo(@"Awaked!");
    if (checkerLoop != nil) {
        [checkerLoop performSelector:@selector(invalidate) onThread:checkerThread withObject:nil waitUntilDone:YES];
        checkerLoop = nil;
        checkerThread = nil;
    }
    
    // And start the thread
    checkerThread = [[NSThread alloc] initWithTarget:self selector:@selector(runLoopAfterAwake) object:nil];
    [checkerThread start];
}

- (IBAction) checkNow:(id)sender {
    if (checkerLoop != nil) {
        [checkerLoop performSelector:@selector(invalidate) onThread:checkerThread withObject:nil waitUntilDone:YES];
        checkerLoop = nil;
        checkerThread = nil;
        if (sender != nil) {
            // Notify the user to give him some feedback
            [GrowlApplicationBridge notifyWithTitle:@"TVShows"
                                        description:TSLocalizeString(@"Checking for new episodes...")
                                   notificationName:@"Checking For New Episodes"
                                           iconData:TVShowsHelperIcon
                                           priority:0
                                           isSticky:0
                                       clickContext:nil];
        }
    }
    
    // And start the thread
    checkerThread = [[NSThread alloc] initWithTarget:self selector:@selector(runLoop) object:nil];
    [checkerThread start];
}

- (void) updateShowList {
    // Create the Preset Torrents Controller and set it with the correct delegates
    PresetTorrentsController *controller = [[PresetTorrentsController alloc] init];
    
    [controller setSubscriptionsDelegate:subscriptionsDelegate];
    [controller setPresetsDelegate:presetShowsDelegate];
    
    NSArrayController *SBArrayController = [[NSArrayController alloc] init];
    NSArrayController *PTArrayController = [[NSArrayController alloc] init];
    [SBArrayController setManagedObjectContext:[subscriptionsDelegate managedObjectContext]];
    [PTArrayController setManagedObjectContext:[presetShowsDelegate managedObjectContext]];
    [SBArrayController setEntityName:@"Subscription"];
    
    if ([SBArrayController fetchWithRequest:nil merge:YES error:nil]) {
        [controller setSBArrayController:SBArrayController];
        [controller setPTArrayController:PTArrayController];
        
        // We can now safely download the torrent show list :)
        [controller downloadTorrentShowList];
    }
    
    // Avoid a memory leak by breaking circular references between these classes 
    [controller setSBArrayController:nil];
    [controller setPTArrayController:nil];
    [controller setSubscriptionsDelegate:nil];
    [controller setPresetsDelegate:nil];
}

- (void) checkAllShows {
    @autoreleasepool {
        // First disable the menubar option
        [self performSelectorOnMainThread:@selector(disableLastCheckedItem) withObject:nil waitUntilDone:NO];
        
        // This is to track changes in the Core Data
        changed = NO;
        
        // Reload the delegates
        subscriptionsDelegate = [[SubscriptionsDelegate alloc] init];
        presetShowsDelegate = [[PresetShowsDelegate alloc] init];
        
        // Update the showlist
        [self updateShowList];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription"
                                                  inManagedObjectContext:[subscriptionsDelegate managedObjectContext]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSArray *results = [[subscriptionsDelegate managedObjectContext] executeFetchRequest:request error:&error];
        
        if (error != nil) {
            LogError(@"%@",[error description]);
        } else {
            // No error occurred so check for new episodes
            LogInfo(@"Checking for new episodes.");
            for (NSArray *show in results) {
                // Only check for new episodes if it's enabled.
                if ([[show valueForKey:@"isEnabled"] boolValue]) {
                    [self checkForNewEpisodes:show];
                }
            }
        }
        
        // And free the delegates
        subscriptionsDelegate = nil;
        presetShowsDelegate = nil;
        
        // Now that everything is done, update the time our last check was made.
        [TSUserDefaults setKey:@"lastCheckedForEpisodes" fromDate:[NSDate date]];
        
        // And update the menu to reflect the date
        [self performSelectorOnMainThread:@selector(updateLastCheckedItem) withObject:nil waitUntilDone:NO];
        
        // And warn the prefpane if needed
        if (changed) {
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TSUpdatedShows" object:nil];
        }
    }
}

- (void) checkForNewEpisodes:(NSArray *)show {
    @autoreleasepool {
        LogDebug(@"Checking episodes for %@.", [show valueForKey:@"name"]);
        
        NSDate *pubDate, *lastDownloaded, *lastChecked;
        BOOL isCustomRSS = ([show valueForKey:@"filters"] != nil);
        BOOL chooseAnyVersion = NO;
        NSArray *episodes = [TSParseXMLFeeds parseEpisodesFromFeeds:
                             [[show valueForKey:@"url"] componentsSeparatedByString:@"#"]
                                                    beingCustomShow:isCustomRSS];
        
        if ([episodes count] == 0) {
            LogDebug(@"No episodes for %@ <%@>", [show valueForKey:@"name"], [show valueForKey:@"url"]);
            return;
        }
        
        // Get the dates before checking anything, in case we have to download more than one episode
        lastDownloaded = [show valueForKey:@"lastDownloaded"];
        lastChecked = [TSUserDefaults getDateFromKey:@"lastCheckedForEpisodes"];
        
        // Filter episodes according to user filters
        if (isCustomRSS) {
            episodes = [episodes filteredArrayUsingPredicate:[show valueForKey:@"filters"]];
        }
        
        NSString *lastEpisodeName = [show valueForKey:@"sortName"];
        
        // For each episode that was parsed...
        for (NSArray *episode in episodes) {
            pubDate = [episode valueForKey:@"pubDate"];
            
            // If the date this torrent was published is newer than the last downloaded episode
            // then we should probably download the episode.
            if ([pubDate compare:lastDownloaded] == NSOrderedDescending) {
                
                // HACK HACK HACK: To avoid download an episode twice
                // Check if the sortname contains this episode name
                // HACK HACK HACK: put on the sortname the episode name
                // Why not storing this on a key? Because Core Data migrations and PrefPanes do not mix well
                NSString *episodeName = [[show valueForKey:@"name"] stringByReplacingOccurrencesOfRegex:@"^The[[:space:]]"
                                                                                             withString:@""];
                episodeName = [episodeName stringByAppendingString:[episode valueForKey:@"episodeName"]];
                
                // Detect if the last downloaded episode was aired after this one (so do not download it!)
                // Use a cache version (lastEpisodename) because we could have download it several episodes
                // in this session, for example if the show aired two episodes in the same day
                // Do not do this for custom RSS
                if (![TSRegexFun wasThisEpisode:episodeName airedAfterThisOne:lastEpisodeName] && !isCustomRSS) {
                    return;
                }
                
                // If it has been 18 hours since the episode was aired attempt the download of any version
                // Also check that we have checked for episodes at least once in the last day
                float anyVersionInterval = [TSUserDefaults getFloatFromKey:@"AnyVersionInterval" withDefault:18];
                
                if ([[NSDate date] timeIntervalSinceDate:pubDate] > anyVersionInterval*60*60 &&
                    ([[NSDate date] timeIntervalSinceDate:lastChecked] < 5*60*60 ||
                     [[NSDate date] timeIntervalSinceDate:lastChecked] < (anyVersionInterval-5)*60*60)) {
                        chooseAnyVersion = YES;
                    } else {
                        chooseAnyVersion = NO;
                    }
                
                // First let's try to download the HD version from the RSS
                // Only if it is HD and HD is enabled (or SD was not available last two days)
                if (([[show valueForKey:@"quality"] boolValue] &&
                     [[episode valueForKey:@"isHD"] boolValue]) ||
                    (![[show valueForKey:@"quality"] boolValue] &&
                     ![[episode valueForKey:@"isHD"] boolValue]) ||
                    chooseAnyVersion) {
                    
                    BOOL downloaded = NO;
                    
                    // Otherwise download the episode! With mirrors (they are stored in a string separated by #)
                    if (!downloaded && [TSTorrentFunctions downloadEpisode:episode ofShow:show]) {
                        downloaded = YES;
                    }
                    
                    // Update the last downloaded episode name only if it was aired after the previous stored one
                    if (downloaded) {
                        if (isCustomRSS && [pubDate compare:[show valueForKey:@"lastDownloaded"]] == NSOrderedDescending) {
                            [show setValue:pubDate forKey:@"lastDownloaded"];
                            [[subscriptionsDelegate managedObjectContext] processPendingChanges];
                            [subscriptionsDelegate saveAction];
                            changed = YES;
                        } else if ([TSRegexFun wasThisEpisode:episodeName
                                            airedAfterThisOne:[show valueForKey:@"sortName"]]) {
                            [show setValue:pubDate forKey:@"lastDownloaded"];
                            [show setValue:episodeName forKey:@"sortName"];
                            [[subscriptionsDelegate managedObjectContext] processPendingChanges];
                            [subscriptionsDelegate saveAction];
                            changed = YES;
                        }
                    }
                }
            } else {
                // The rest is not important because it is even before the previous entry
                return;
            }
            
        }
    }
}

#pragma mark - Status Menu

- (void) activateStatusMenu {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    [statusItem setImage:[NSImage imageNamed:@"TVShows-Menu-Icon-Black"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"TVShows-Menu-Icon-White"]];
    [statusItem setEnabled:YES];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
    
    [statusItem setAction:@selector(openApplication:)];
    [statusItem setMenu:statusMenu];
    
    // Localize
    [lastUpdateItem setTitle:[NSString stringWithFormat:@"%@ %@", TSLocalizeString(@"Last Checked:"), TSLocalizeString(@"Never")]];
    [checkShowsItem setTitle:TSLocalizeString(@"Checking now, please wait...")];
    [subscriptionsItem setTitle:[NSString stringWithFormat:@"%@...", TSLocalizeString(@"Subscriptions")]];
    [preferencesItem setTitle:[NSString stringWithFormat:@"%@...", TSLocalizeString(@"Preferences")]];
    [feedbackItem setTitle:[NSString stringWithFormat:@"%@...", TSLocalizeString(@"Submit Feedback")]];
    [aboutItem setTitle:[NSString stringWithFormat:@"%@ TVShows", TSLocalizeString(@"About")]];
    [disableItem setTitle:TSLocalizeString(@"Disable TVShows")];
}

- (void) disableLastCheckedItem {
    // Disable the menubar option
    [checkShowsItem setAction:nil];
    [checkShowsItem setTitle:TSLocalizeString(@"Checking now, please wait...")];
}

- (void) updateLastCheckedItem {
    // We have to build a localized string with the date info
    // Prepare the date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // Create the string from this date
    NSString *formattedDateString = [dateFormatter stringFromDate:[TSUserDefaults getDateFromKey:@"lastCheckedForEpisodes"]];
    
    // Finally, update the string
    [lastUpdateItem setTitle:[NSString stringWithFormat:@"%@ %@", TSLocalizeString(@"Last Checked:"), formattedDateString]];
    
    // Enable again the menubar option
    [checkShowsItem setAction:@selector(checkNow:)];
    [checkShowsItem setTitle:TSLocalizeString(@"Check for new episodes now")];
}

- (IBAction) openApplication:(id)sender {
    BOOL success = [[NSWorkspace sharedWorkspace] openFile:
                    [[[NSBundle bundleWithIdentifier:TVShowsAppDomain] bundlePath] stringByExpandingTildeInPath]];
    
    if (!success) {
        LogError(@"Application did not open at request.");
    }
}

- (void) openTab:(NSInteger)tabNumber {
    NSString *command = [NSString stringWithFormat:
                         @"tell application \"System Preferences\"                               \n"
                         @"   activate                                                           \n"
                         @"   set the current pane to pane id \"com.victorpimentel.TVShows2\"    \n"
                         @"end tell                                                              \n"
                         @"tell application \"System Events\"                                    \n"
                         @"    tell process \"System Preferences\"                               \n"
                         @"        click radio button %ld of tab group 1 of window \"TVShows\"    \n"
                         @"    end tell                                                          \n"
                         @"end tell                                                    ", (long)tabNumber];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/osascript"];
    [task setArguments:[NSMutableArray arrayWithObjects:@"-e", command, nil]];
    [task launch];
}

- (IBAction) showSubscriptions:(id)sender {
    [self openTab:1];
}

- (IBAction) showPreferences:(id)sender {
    [self openTab:2];
}

- (IBAction) showAbout:(id)sender {
    [self openTab:3];
}

- (IBAction) showFeedback:(id)sender {
    NSString *command =
    @"tell application \"System Preferences\"                               \n"
    @"   activate                                                           \n"
    @"   set the current pane to pane id \"com.victorpimentel.TVShows2\"    \n"
    @"end tell                                                              \n"
    @"tell application \"System Events\"                                    \n"
    @"    tell process \"System Preferences\"                               \n"
    @"        click button 4 of window \"TVShows\"                          \n"
    @"    end tell                                                          \n"
    @"end tell                                                              ";
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/osascript"];
    [task setArguments:[NSMutableArray arrayWithObjects:@"-e", command, nil]];
    [task launch];
}

- (IBAction) quitHelper:(id)sender {
    [[[PreferencesController alloc] init] enabledControlDidChange:NO];
    [NSApp terminate:sender];
}

#pragma mark - Sparkle Delegate Methods

- (void) updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update {
    // We use this to help no whether or not the TVShowsHelper should close after
    // downloading new episodes or whether it should wait for Sparkle to finish
    // installing new updates.
    LogDebug(@"Sparkle found a valid update.");
    
    // If the user has automatic updates turned on, set a value saying that we installed
    // an update in the background and send a Growl notification.
    if ([TSUserDefaults getBoolFromKey:@"SUAutomaticallyUpdate" withDefault:YES]) {
        [TSUserDefaults setKey:@"AutomaticallyInstalledLastUpdate" fromBool:YES];
        
        if([TSUserDefaults getBoolFromKey:@"GrowlOnAppUpdate" withDefault:YES]) {
            [GrowlApplicationBridge notifyWithTitle:@"TVShows Update Downloading"
                                        description:TSLocalizeString(@"A new version of TVShows is being downloaded and installed.")
                                   notificationName:@"TVShows Update Downloaded"
                                           iconData:TVShowsHelperIcon
                                           priority:0
                                           isSticky:0
                                       clickContext:nil];
        }
    } else if([TSUserDefaults getBoolFromKey:@"GrowlOnAppUpdate" withDefault:YES]) {
        [GrowlApplicationBridge notifyWithTitle:@"TVShows Update Available"
                                    description:TSLocalizeString(@"A new version of TVShows is available for download.")
                               notificationName:@"TVShows Update Available"
                                       iconData:TVShowsHelperIcon
                                       priority:0
                                       isSticky:YES
                                   clickContext:nil];
    }
}

- (void)updater:(SUUpdater *)updater willInstallUpdate:(SUAppcastItem *)update {
    // Relaunch the TVShows Helper :)
    NSString *daemonPath = [[NSBundle bundleWithIdentifier: TVShowsAppDomain] pathForResource:@"relaunch" ofType:nil];
    NSString *launchAgentPath = [[[PreferencesController alloc] init] launchAgentPath];
    
    [NSTask launchedTaskWithLaunchPath:daemonPath
                             arguments:[NSArray arrayWithObjects:launchAgentPath, @"",
                                        [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]], nil]];
    
    LogInfo(@"Relaunching TVShows Helper after the successful update.");
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
