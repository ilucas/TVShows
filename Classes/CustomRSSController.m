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

#import "CustomRSSController.h"
#import "TabController.h"

#import "TSParseXMLFeeds.h"
#import "TSUserDefaults.h"
#import "TSRegexFun.h"

#import "RegexKitLite.h"

#define DEFAULT_PREDICATE [NSCompoundPredicate andPredicateWithSubpredicates:\
    [NSArray arrayWithObject:[NSPredicate predicateWithFormat:@"episodeName contains[cd] ' '"]]]

@implementation CustomRSSController

@synthesize selectedShow;

- init
{
    if((self = [super init])) {
        isTranslated = NO;
        selectedShow = nil;
        filterRules = DEFAULT_PREDICATE;
    }
    
    return self;
}

- (void) localizeWindow
{
    [rssSectionTitle setStringValue: TSLocalizeString(@"RSS Feed Information:")];
    [filterSectionTitle setStringValue: TSLocalizeString(@"Only download items matching the following rules:")];
    [nameText setStringValue: [NSString stringWithFormat:@"%@:", TSLocalizeString(@"Name")]];
    [feedText setStringValue: [NSString stringWithFormat:@"%@:", TSLocalizeString(@"Feed URLs")]];
    [tvdbText setStringValue: [NSString stringWithFormat:@"%@:", TSLocalizeString(@"TVDB id")]];
    [showQuality setTitle: TSLocalizeString(@"Download in HD")];
    [cancelButton setTitle: TSLocalizeString(@"Cancel")];
    
    // Localize the headings of the table columns
    [[colHD headerCell] setStringValue: TSLocalizeString(@"HD")];
    [[colName headerCell] setStringValue: TSLocalizeString(@"Episode Name")];
    [[colSeason headerCell] setStringValue: TSLocalizeString(@"Season")];
    [[colEpisode headerCell] setStringValue: TSLocalizeString(@"Episode")];
    [[colDate headerCell] setStringValue: TSLocalizeString(@"Published Date")];
    
    isTranslated = YES;
}

- (IBAction) displayCustomRSSWindow:(id)sender
{
    // Localize things (only needed the first time)
    if(isTranslated == NO) {
        [self localizeWindow];
    }
    
    // Just in case localize the subscribe button
    [subscribeButton setTitle: TSLocalizeString(@"Subscribe")];
    selectedShow = nil;
    
    filterRules = DEFAULT_PREDICATE;
    
    [filtersEditor setObjectValue:filterRules];
    [episodeArrayController setFilterPredicate:filterRules];
    
    [self resetShowView];
    
    // At least a feed must be set
    [self addFeed:nil];
    
    [NSApp beginSheet: CustomRSSWindow
       modalForWindow: [[NSApplication sharedApplication] mainWindow]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp endSheet: CustomRSSWindow];
    [NSApp runModalForWindow: CustomRSSWindow];
}

- (IBAction) displayEditWindow:(id)sender
{
    // Localize things (only needed the first time)
    if(isTranslated == NO) {
        [self localizeWindow];
    }
    
    // Localize the subscribe button (now called save)
    [subscribeButton setTitle:TSLocalizeString(@"Save")];
    
    // Get the data and close the modal window
    TabController *infoController = [[sender cell] representedObject];
    selectedShow = [infoController selectedShow];
    [infoController closeShowInfoWindow:nil];
    
    // Set the filter rules
    filterRules = [selectedShow valueForKey:@"filters"];
    
    if (filterRules == nil) {
        filterRules = DEFAULT_PREDICATE;
    }
    
    [filtersEditor setObjectValue:filterRules];
    [episodeArrayController setFilterPredicate:filterRules];
    
    // Set the info
    [nameValue setStringValue:[selectedShow valueForKey:@"name"]];
    [tvdbValue setStringValue:[NSString stringWithFormat:@"%@", [selectedShow valueForKey:@"tvdbID"]]];
    [showQuality setState:[[selectedShow valueForKey:@"quality"] intValue]];
//    [showQuality setEnabled:YES];
    [subscribeButton setEnabled:YES];
    [self showQualityDidChange:nil];
    
    // Add the feeds
    [feedArrayController removeObjects:[feedArrayController content]];
    for (NSString *feed in [[selectedShow valueForKey:@"url"] componentsSeparatedByString:@"#"]) {
        if (![feed isEqualToString:@""]) {
            [self addFeed:feed];
        }
    }
    
    // Update the episode list
    [self controlTextDidEndEditing:nil];
    
    [NSApp beginSheet: CustomRSSWindow
       modalForWindow: [[NSApplication sharedApplication] mainWindow]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp endSheet: CustomRSSWindow];
    [NSApp runModalForWindow: CustomRSSWindow];
}

- (IBAction) addFeed:(id)sender {
    // Set the text
    NSMutableDictionary *newFeed = [NSMutableDictionary dictionary];
    if (sender != nil && [sender isKindOfClass:[NSString class]]) {
        [newFeed setValue:sender forKey:@"url"];
    } else {
        [newFeed setValue:@"http://" forKey:@"url"];
    }
    
    // Add the new row
    [feedArrayController addObject:newFeed];
    
    // Select the last row!
    NSInteger lastRow = [feedsValue numberOfRows]-1;
    [feedsValue selectRowIndexes:[NSIndexSet indexSetWithIndex:lastRow] byExtendingSelection:NO];
    
    // And edit it if the user added a new row
    if (sender == nil || ![sender isKindOfClass:[NSString class]]) {
        [feedsValue editColumn:0 row:lastRow withEvent:nil select:YES];
    }
}

- (IBAction) removeFeed:(id)sender {
    NSInteger selectedRow = [feedsValue selectedRow];
    
    // If something is selected, remove it
    if (selectedRow != -1) {
        [feedArrayController removeObjectAtArrangedObjectIndex:selectedRow];
        
        // If there are no more entries, add one
        if ([[feedArrayController arrangedObjects] count] == 0) {
            [self addFeed:nil];
        } else {
            // Then just select the previous row
            NSInteger previousRow = selectedRow - 1;
            if (previousRow == -1) {
                previousRow = 0;
            }
            
            [feedsValue selectRowIndexes:[NSIndexSet indexSetWithIndex:previousRow] byExtendingSelection:NO];
        }
        
        // Force changes!
        [self controlTextDidEndEditing:nil];
    }
}

- (void) controlTextDidEndEditing:(NSNotification *)notification
{
    // Check if the field that changed was the name or the feed URL
    if (notification != nil && [notification object] == nameValue) {
        NSString *cleanName = [[nameValue stringValue] stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Enable the subscription if there is a name and there are episodes
        if (![cleanName isEqualToString:@""]) {
            [subscribeButton setEnabled:YES];
//            [showQuality setEnabled:YES];
//            [showQuality setState:NO];
            
            // Update the filter predicate to only display the correct quality.
//            [self showQualityDidChange:nil];
        } else {
            // Otherwise disallow the subscription to this invalid show
            [subscribeButton setEnabled:NO];
        }
    } else {
        NSArray *feeds = [[feedArrayController arrangedObjects] performSelector:@selector(valueForKey:) withObject:@"url"];
        
        // Try to set the new episodes
        [self performSelectorInBackground:@selector(setEpisodesFromRSS:) withObject:feeds];
    }
}

- (void) setEpisodesFromRSS:(NSArray *)feeds
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Now we can trigger the time-expensive task
    NSArray *results = [NSArray arrayWithObjects:feeds,
                        [TSParseXMLFeeds parseEpisodesFromFeeds:feeds beingCustomShow:YES], nil];
    
    [self performSelectorOnMainThread:@selector(updateEpisodes:) withObject:results waitUntilDone:NO];
    
    [pool drain];
}

- (void) updateEpisodes:(NSArray *)data
{
    // Extract the data
    NSArray *feeds = [data objectAtIndex:0];
    NSArray *results = [data objectAtIndex:1];
    
    // We are back after probably a lot of time, so check carefully if the user has changed the text field
    NSArray *copy = [[feedArrayController arrangedObjects] performSelector:@selector(valueForKey:) withObject:@"url"];
    
    // Continue only if the selected show is the same as before
    if ([feeds isEqualToArray:copy]) {
        [episodeArrayController removeObjects:[episodeArrayController content]];
        if ([results count] == 0) {
            [nameValue removeAllItems];
            NSString *cleanName = [[nameValue stringValue] stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // Enable the subscription if there is a name and there are episodes
            if (![cleanName isEqualToString:@""] &&
                ![[copy objectAtIndex:0] isEqualToString:@""] &&
                ![[copy objectAtIndex:0] isEqualToString:@"http://"]) {
                [subscribeButton setEnabled:YES];
//                [showQuality setEnabled:YES];
//                [showQuality setState:NO];
                
                // Update the filter predicate to only display the correct quality.
                [self showQualityDidChange:nil];
            }
        } else {
            [episodeArrayController addObjects:results];
            
            // Check if there are HD episodes, if so enable the "Download in HD" checkbox
//            BOOL feedHasHDEpisodes = [TSParseXMLFeeds feedHasHDEpisodes:results];
            
//            if (feedHasHDEpisodes) {
//                [showQuality setEnabled:YES];
//            } else {
//                [showQuality setState:NO];
//            }
            
            // Update the filter predicate to only display the correct quality.
            [self showQualityDidChange:nil];
            
            // Allow the subscription!
            NSString *cleanName = [[nameValue stringValue] stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // Enable the subscription if there is a name and there are episodes
            if (![cleanName isEqualToString:@""]) {
                [subscribeButton setEnabled:YES];
            }
            
            // Set the possible names for autocompletion
            [self setPossibleNamesFromFeed];
        }
    }
}

- (void) setPossibleNamesFromFeed
{
    // Remove the previous data
    [nameValue removeAllItems];
    
    NSMutableSet *shows = [[[NSMutableSet alloc] init] autorelease];
    
    // Add every show name to a set (to avoid repetitions)
    for (NSDictionary *episode in [episodeArrayController content]) {
        [shows addObject:[TSRegexFun parseShowFromTitle:[episode valueForKey:@"episodeName"]]];
    }
    
    // And finally update the object!
    [nameValue addItemsWithObjectValues:[shows allObjects]];
}

- (void) resetShowView
{
    [episodeArrayController removeObjects:[episodeArrayController content]];
    [feedArrayController removeObjects:[feedArrayController content]];
    [nameValue setStringValue:@""];
    [tvdbValue setStringValue:@""];
    [self setUserDefinedShowQuality];
//    [showQuality setEnabled:NO];
    [subscribeButton setEnabled:NO];
}

- (void) setUserDefinedShowQuality {
    [showQuality setState: [TSUserDefaults getBoolFromKey:@"AutoSelectHDVersion" withDefault:NO]];
}

- (IBAction) showQualityDidChange:(id)sender
{
    // Mix HD option with the filters
    if ([showQuality state]) {
        [episodeArrayController setFilterPredicate:
         [NSCompoundPredicate andPredicateWithSubpredicates:
          [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"isHD == '1'"], filterRules, nil]]];
    } else if (![showQuality state]) {
        [episodeArrayController setFilterPredicate:
         [NSCompoundPredicate andPredicateWithSubpredicates:
          [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"isHD == '0'"], filterRules, nil]]];
    }
}

- (IBAction) closeCustomRSSWindow:(id)sender
{
    [episodeArrayController setFilterPredicate:nil];
    [NSApp stopModal];
    [CustomRSSWindow orderOut:self];
}

#pragma mark -
#pragma mark Subscription Methods
- (IBAction) subscribeToShow:(id)sender
{
    // Close the modal dialog box
    [self closeCustomRSSWindow:(id)sender];
    
    // Calculate the sort name, i.e. remove "The"
    NSString *sortName = [[nameValue stringValue] stringByReplacingOccurrencesOfRegex:@"^The[[:space:]]"
                                                                           withString:@""];
    
    // Build the url for storage (joining them with #)
    NSString *url = [[[feedArrayController arrangedObjects] performSelector:@selector(valueForKey:)
                                                                 withObject:@"url"]
                     componentsJoinedByString:@"#"];
    
    NSManagedObject *subscription;
    
    // Depending on which the show is new or we were editing the show, retrieve it from Core Data
    if (selectedShow != nil) {
        subscription = [[subscriptionsDelegate managedObjectContext] objectWithID:[selectedShow objectID]];
        // Refresh the show from the subscriptions (it may have changed)
        [[subscriptionsDelegate managedObjectContext] refreshObject:subscription mergeChanges:YES];
    } else {
        subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription"
                                                     inManagedObjectContext:[subscriptionsDelegate managedObjectContext]];
        // Enable the new show
        [subscription setValue:[NSNumber numberWithBool:YES] forKey:@"isEnabled"];
    }
    
    // Update the per-show preferences
    [subscription setValue:[nameValue stringValue] forKey:@"name"];
    [subscription setValue:sortName forKey:@"sortName"];
    [subscription setValue:url forKey:@"url"];
    [subscription setValue:[NSNumber numberWithInt:[[tvdbValue stringValue] intValue]] forKey:@"tvdbID"];
    [subscription setValue:[NSDate date] forKey:@"lastDownloaded"];
    [subscription setValue:[NSNumber numberWithInt:[showQuality state]] forKey:@"quality"];
    [subscription setValue:filterRules forKey:@"filters"];
    
    // Be sure to process pending changes before saving or it won't save correctly
    [[subscriptionsDelegate managedObjectContext] processPendingChanges];
    [subscriptionsDelegate saveAction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSUpdatedShows"
                                                        object:nil
                                                      userInfo:(NSDictionary *)subscription];
}

- (void)dealloc
{
    [filterRules release];
    [super dealloc];
}

@end
