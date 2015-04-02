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

#import "MisoController.h"
#import "AppInfoConstants.h"
#import "TSUserDefaults.h"
#import "TheTVDB.h"
#import "TSRegexFun.h"

@implementation MisoController

- (id)init
{
    self = [super init];
    if (self) {
        misoBackend = [[Miso alloc] init];
        [misoBackend setDelegate:self];
        signInProgress = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addSubscription:)
                                                     name:@"TSAddSubscription"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeSubscription:)
                                                     name:@"TSRemoveSubscription"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkinEpisode:)
                                                     name:@"TSDownloadEpisode"
                                                   object:nil];
    }
    
    return self;
}

- (void)localize
{
    [misoText setStringValue:TSLocalizeString(@"Miso is a social network made for people that love watching TV shows.")];
    [existingUserText setStringValue:TSLocalizeString(@"I am already a Miso user")];
    [whyText setStringValue:TSLocalizeString(@"Why try it?")];
    [becauseText setStringValue:TSLocalizeString(@"Your subscriptions will be backed up in the cloud and they can be synced between different computers.")];
    
    [nameTitle setStringValue:TSLocalizeString(@"User Name:")];
    [passwordTitle setStringValue:TSLocalizeString(@"Password:")];
    
    [loginButton setTitle:TSLocalizeString(@"Sign In")];
    [signUpButton setTitle:TSLocalizeString(@"Create New Account")];
    [logOutButton setTitle:TSLocalizeString(@"Sign Out")];
    [visitButton setTitle:TSLocalizeString(@"Visit Miso")];
    
    [syncCheck setTitle:TSLocalizeString(@"Sync shows between Miso and TVShows")];
    [syncText setStringValue:TSLocalizeString(@"Your TVShows subscriptions will be automatically synced with your followed shows on Miso. Only airings shows known by TVShows will be synced.")];
    [checkinCheck setTitle:TSLocalizeString(@"Automatic check-in when an episode is downloaded")];
    [checkinText setStringValue:TSLocalizeString(@"The check-in will be made when the download starts. This is not advisable, but it could allow you to sync episode downloads across several computers.")];
}

- (void)awakeFromNib
{
    [self localize];
    
    if ([TSUserDefaults getBoolFromKey:@"MisoEnabled" withDefault:NO]) {
        signInProgress = YES;
        manually = NO;
        // Try to login
        [misoBackend authorizeWithKey:MISO_API_KEY secret:MISO_API_SECRET];
    }
}

- (void)authenticationEnded:(BOOL)authenticated
{
    if (signInProgress) {
        if (authenticated) {
            [TSUserDefaults setKey:@"MisoEnabled" fromBool:YES];
            
            // Get the user defaults
            [syncCheck setState:[TSUserDefaults getBoolFromKey:@"MisoSyncEnabled" withDefault:YES]];
            [checkinCheck setState:[TSUserDefaults getBoolFromKey:@"MisoCheckInEnabled" withDefault:NO]];
            
            // Change to the new view
            [tabView selectTabViewItemAtIndex:1];
            
            if (manually) {
                [nameField setBackgroundColor:[NSColor whiteColor]];
                [passwordField setBackgroundColor:[NSColor whiteColor]];
                [nameField setStringValue:@""];
                
                // This will take some time
                [self syncButtonDidChange:nil];
                
                // Warn the helper that now it can synchronize with Miso
                [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TSMisoAuthenticated"
                                                                               object:nil];
            }
        } else {
            [TSUserDefaults setKey:@"MisoEnabled" fromBool:NO];
            if (manually) {
                [nameField setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:0.8 blue:0.8 alpha:1.0]];
                [passwordField setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:0.8 blue:0.8 alpha:1.0]];
                
                // Change to the new view
                [tabView selectTabViewItemAtIndex:0];
            }
        }
    }
    
    // Back to normal
    signInProgress = NO;
    [loading stopAnimation:nil];
    [nameTitle setEnabled:YES];
    [nameField setEnabled:YES];
    [passwordTitle setEnabled:YES];
    [passwordField setEnabled:YES];
    [loginButton setEnabled:YES];
}

- (IBAction)signIn:(id)sender {
    // Set the flags
    signInProgress = YES;
    manually = YES;
    
    NSString *userName = [nameField stringValue];
    NSString *password = [passwordField stringValue];
    
    // Start loading throbber
    [loading startAnimation:nil];
    
    // Disable form
    [nameTitle setEnabled:NO];
    [nameField setEnabled:NO];
    [passwordTitle setEnabled:NO];
    [passwordField setEnabled:NO];
    [loginButton setEnabled:NO];
    
    // Start request
    [misoBackend authorizeWithKey:MISO_API_KEY
                           secret:MISO_API_SECRET
                         userName:userName
                      andPassword:password];
}

- (IBAction)createAccount:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:MisoWebsite]];
}

- (IBAction)syncButtonDidChange:(id)sender {
    [TSUserDefaults setKey:@"MisoSyncEnabled" fromBool:[syncCheck state]];
    
    if ([syncCheck state]) {
        [TSUserDefaults setKey:@"MisoSyncInProgress" fromBool:YES];
        [loading startAnimation:nil];
        [self performSelector:@selector(syncShows) withObject:nil afterDelay:0.5];
    }
}

- (IBAction)checkinCheckDidChange:(id)sender {
    [TSUserDefaults setKey:@"MisoCheckInEnabled" fromBool:[checkinCheck state]];
}

- (IBAction)logOut:(id)sender {
    [misoBackend forgetAuthorization];
    [TSUserDefaults setKey:@"MisoEnabled" fromBool:NO];
    [tabView selectTabViewItemAtIndex:0];
}

- (NSObject *)getShow:(NSString *)showId fromList:(NSEnumerator *)list
{
    for (NSObject *show in list) {
        if ([[[show valueForKey:@"tvdbID"] description] isEqualToString:showId]) {
            return show;
        }
    }
    
    return nil;
}

- (NSObject *)getShow:(NSString *)showId fromDictionary:(NSDictionary *)dict
{
    for (NSObject *show in dict) {
        if ([[[[show valueForKey:@"media"] valueForKey:@"tvdb_id"] description] isEqualToString:showId]) {
            return show;
        }
    }
    
    return nil;
}

- (void)subscribeToFollowedShows:(NSDictionary *)followedShows
{
    // The other way around, update our subscriptions with the followed shows on Miso
    for (NSDictionary *show in followedShows) {
        // Get the precious data for that show
        NSString *showID = [[[show valueForKey:@"media"] valueForKey:@"tvdb_id"] description];
        NSString *seriesName = [[show valueForKey:@"media"] valueForKey:@"title"];
        
        // Let's check that the show is in the preset show list
        NSObject *selectedShow = [self getShow:showID fromList:[PTArrayController arrangedObjects]];
        
        // Some shows do not have TVDB ids yet; try to map them together
        if (!selectedShow && (!showID || [showID isEqualToString:@"<null>"] || [showID length] == 0)) {
            // Just pick the first show with that name, if there is any
            for (NSObject *presetShow in [PTArrayController arrangedObjects]) {
                if ([[presetShow valueForKey:@"displayName"] isEqualToString:seriesName]) {
                    selectedShow = presetShow;
                    showID = [[presetShow valueForKey:@"tvdbID"] description];
                    break;
                }
            }
        }
        
        // If the user is not subscribed to this show and the show is still airing, add to the subscriptions
        if (selectedShow && ![self getShow:showID fromList:[SBArrayController arrangedObjects]] &&
            ![[TheTVDB getShowStatus:seriesName withShowID:showID] isEqualToString:@"Ended"]) {
            
            LogInfo(@"Adding show %@ from Miso.", seriesName);
            
            NSManagedObject *newSubscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription"
                                                                             inManagedObjectContext:[subscriptionsDelegate managedObjectContext]];
            
            // Set the information about the new show
            [newSubscription setValue:[selectedShow valueForKey:@"displayName"] forKey:@"name"];
            [newSubscription setValue:[selectedShow valueForKey:@"sortName"] forKey:@"sortName"];
            [newSubscription setValue:[selectedShow valueForKey:@"tvdbID"] forKey:@"tvdbID"];
            [newSubscription setValue:[selectedShow valueForKey:@"name"] forKey:@"url"];
            [newSubscription setValue:[NSNumber numberWithBool:[TSUserDefaults getBoolFromKey:@"AutoSelectHDVersion" withDefault:NO]]
                               forKey:@"quality"];
            [newSubscription setValue:[NSNumber numberWithBool:YES] forKey:@"isEnabled"];
            
            // OK, so we know that the user has Miso.
            // And that the user has followed a "new" show.
            // So let's go back in time six days so that the last episodes
            // will be downloaded. So that user can leverage this Miso synchronization.
            // If the user does not want to download an episode he can cancel,
            // but the other user case is more cumbersome.
            // Anyway, if the user did a check-in for th(at/ose) episode(s)
            // it will not be downloaded (and again, the user is Miso synced)
            [newSubscription setValue:[NSDate dateWithTimeIntervalSinceNow:-6*24*60*60] forKey:@"lastDownloaded"];
            
            // To sort the list when we add the shows
            [SBArrayController setUsesLazyFetching:NO];
            [SBArrayController addObject:newSubscription];
            
            [[subscriptionsDelegate managedObjectContext] processPendingChanges];
            [subscriptionsDelegate saveAction];
        }
    }
}

- (void)followShow:(NSDictionary *)show
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Search for it on Miso
    NSDictionary *results = [misoBackend showWithQuery:[show valueForKey:@"name"]];
    
    // Filter those results by TVDB id
    NSObject *newShow = [self getShow:[[show valueForKey:@"tvdbID"] description] fromDictionary:results];
    
    // Some shows do not have TVDB ids yet; try to map them together
    if (!newShow) {
        // Just pick the first show (too late, I cannot even think anymore)
        for (NSObject *result in results) {
            newShow = result;
            break;
        }
        // If the name is not equal... go back
        if (newShow && ![[[newShow valueForKey:@"media"] valueForKey:@"title"] isEqualToString:[show valueForKey:@"name"]]) {
            newShow = nil;
        }
    }
    
    // At this point, it should be a valid show, but maybe it is not on the Miso database yet
    if (newShow && ![[[newShow valueForKey:@"media"] valueForKey:@"currently_favorited"] boolValue]) {
        LogInfo(@"Adding show %@ on Miso.", [show valueForKey:@"name"]);
        
        [misoBackend favoriteShow:[[[newShow valueForKey:@"media"] valueForKey:@"id"] description]];
    }
    
    [pool drain];
}

- (void)followSubscriptions:(NSDictionary *)followedShows
{
    // Follow on Miso our (this is made only when the user manually enter the credentials)
    for (NSDictionary *show in [SBArrayController arrangedObjects]) {
        // Get the TVDB id
        NSString *showID = [[show valueForKey:@"tvdbID"] description];
        
        // Disregard custom RSS and check if the show is been already followed
        if (showID && ![show valueForKey:@"filters"] &&
            ![self getShow:showID fromDictionary:followedShows]) {
            [self followShow:show];
        }
    }
}

- (void)unfollowShow:(NSDictionary *)show
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Search for it on Miso
    NSDictionary *results = [misoBackend showWithQuery:[show valueForKey:@"name"]];
    
    // Filter those results by TVDB id
    NSObject *newShow = [self getShow:[[show valueForKey:@"tvdbID"] description] fromDictionary:results];
    
    // Some shows do not have TVDB ids yet; try to map them together
    if (!newShow) {
        // Just pick the first show (too late, I cannot even think anymore)
        for (NSObject *result in results) {
            newShow = result;
            break;
        }
        // If the name is not equal... go back
        if (newShow && ![[[newShow valueForKey:@"media"] valueForKey:@"title"] isEqualToString:[show valueForKey:@"name"]]) {
            newShow = nil;
        }
    }
    
    // At this point, it should be a valid show, but maybe it is not on the Miso database yet
    if (newShow && [[[newShow valueForKey:@"media"] valueForKey:@"currently_favorited"] boolValue]) {
        LogInfo(@"Removing show %@ from Miso.", [show valueForKey:@"name"]);
        
        [misoBackend unfavoriteShow:[[[newShow valueForKey:@"media"] valueForKey:@"id"] description]];
    }
    
    [pool drain];
}

- (void)syncShows
{
    // Check the followed shows and process them
    NSDictionary *followedShows = [misoBackend favoritedShows];
    
    // Only try to add shows, do not remove them!
    [self followSubscriptions:followedShows];
    [self subscribeToFollowedShows:followedShows];
    [TSUserDefaults setKey:@"MisoSyncInProgress" fromBool:NO];
    
    [SBArrayController setManagedObjectContext:[subscriptionsDelegate managedObjectContext]];
    
    [loading stopAnimation:nil];
}

- (void)addSubscription:(NSNotification *)inNotification
{
    if ([TSUserDefaults getBoolFromKey:@"MisoEnabled" withDefault:NO] &&
        [TSUserDefaults getBoolFromKey:@"MisoSyncEnabled" withDefault:YES]) {
        // Retrieve the show data and follow the leader, leader, leader
        [self performSelectorInBackground:@selector(followShow:) withObject:[inNotification userInfo]];
    }
}

- (void)removeSubscription:(NSNotification *)inNotification
{
    if ([TSUserDefaults getBoolFromKey:@"MisoEnabled" withDefault:NO] &&
        [TSUserDefaults getBoolFromKey:@"MisoSyncEnabled" withDefault:YES]) {
        // Disregard custom RSS
        if (![[inNotification userInfo] valueForKey:@"filters"]) {
            // Copy the data of the show because, in the background, the object will not exists :(
            NSDictionary *show = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [[inNotification userInfo] valueForKey:@"name"], @"name",
                                  [[inNotification userInfo] valueForKey:@"tvdbID"], @"tvdbID", nil];
            [self performSelectorInBackground:@selector(unfollowShow:) withObject:show];
        }
    }
}

- (void)checkinEpisode:(NSNotification *)inNotification
{
    if ([TSUserDefaults getBoolFromKey:@"MisoEnabled" withDefault:NO] &&
        [TSUserDefaults getBoolFromKey:@"MisoCheckInEnabled" withDefault:NO]) {
        
        NSString *episodeName = [[inNotification userInfo] valueForKey:@"episodeName"];
        NSString *showName = [[inNotification userInfo] valueForKey:@"showName"];
        
        NSArray *seasonAndEpisode = [TSRegexFun parseSeasonAndEpisode:episodeName];
        
        if ([seasonAndEpisode count] == 3) {
            
            // Search for it on Miso
            NSDictionary *results = [misoBackend showWithQuery:showName];
            
            NSObject *show = nil;
            
            // Just pick the first show (too late, I cannot even think anymore)
            for (NSObject *result in results) {
                show = result;
                break;
            }
            
            // At this point, it should be a valid show, but maybe it is not on the Miso database yet
            if (show) {
                LogInfo(@"Adding check-in for %@ on Miso.", episodeName);
                
                [misoBackend addCheckingForShow:[[[show valueForKey:@"media"] valueForKey:@"id"] description]
                                  withSeasonNum:[TSRegexFun removeLeadingZero:[seasonAndEpisode objectAtIndex:1]]
                                     episodeNum:[TSRegexFun removeLeadingZero:[seasonAndEpisode objectAtIndex:2]]];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [misoBackend release];
    [super dealloc];
}

@end
