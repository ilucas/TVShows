//
//  SubscriptionWindowController.m
//  TVShows
//
//  Created by Lucas on 02/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "SubscriptionWindowController.h"
#import "TVRage.h"
#import "TheTVDB.h"
#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

@interface SubscriptionWindowController ()

#pragma mark - Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Bindings
@property (strong) NSMutableArray *sorter;
@property (readwrite, strong, nonatomic) NSMutableArray *showList;

- (void)toggleLoading:(BOOL)isLoading;
- (void)updateShowInfo:(Serie *)serie;
- (BOOL)userIsSubscribedToShow:(Serie *)serie;
- (void)resetShowView;
@end

@implementation SubscriptionWindowController
@synthesize managedObjectContext;

#pragma mark - Lifecycle

- (void)awakeFromNib {
    
}

- (instancetype)init {
    return [self initWithWindowNibName:@"SubscriptionWindowController"];
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        _showList = [[NSMutableArray alloc] init];
        _episodesList = [[NSMutableArray alloc] init];
        _sorter = [NSMutableArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    }
    
    return self;
}

#pragma mark - Actions

- (IBAction)openMoreInfoURL:(id)sender {

}

- (IBAction)closeWindow:(id)sender {
    [self close];
}

- (IBAction)subscribeToShow:(id)sender {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSDictionary *selectedObject = [[self.showsArrayController selectedObjects] firstObject];
        Serie  *serie = [Serie MR_findFirstByAttribute:@"tvdb_id" withValue:selectedObject[@"tvdb_id"] inContext:localContext];
        
        Subscription *subscription = [Subscription MR_createInContext:localContext];
        [subscription setIsEnabledValue:YES];
        [subscription setSerie:serie];
    } completion:^(BOOL success, NSError *error) {
        //TODO: Send a subscribed notification
    }];
    
    // Close window after subscribe to show.
    [self closeWindow:nil];
}

- (IBAction)selectNextAired:(id)sender {
    [self.episodesTableView setEnabled:NO];
}

- (IBAction)selectOtherEpisode:(id)sender {
    [self.episodesTableView setEnabled:YES];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    NSString *search = [[notification object] stringValue];
    
    if ([search isEmpty]){
        [self.showList removeAllObjects];
        [self.showsTableView reloadData];
        return;
    }
    
    [[TheTVDB sharedInstance] searchShow:search completionHandler:^(NSArray *result, NSError *error) {
        if (result) {
            [self.showList removeAllObjects];
            [self.showsArrayController addObjects:result];
            
            // Select the first item in TableView if not empty.
            if (self.showList.count > 0)
                [self.showsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }
    }];
}

#pragma mark - NSWindowDelegate

- (void)windowDidLoad {
    [super windowDidLoad];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSDictionary __block *selectedObject = [[self.showsArrayController selectedObjects] firstObject];
    [self resetShowView];
    
    if (selectedObject) {
        NSNumber *thetvdbid = selectedObject[@"tvdb_id"];
        Serie __block *serie = [Serie MR_findFirstByAttribute:@"tvdb_id" withValue:thetvdbid inContext:self.managedObjectContext];
        
        // download serie info if is not already cached
        if (serie) {
            [self toggleLoading:NO];
            [self updateShowInfo:serie];
        } else {
            [self toggleLoading:YES];
            
            [[TheTVDB sharedInstance] getShowWithEpisodeList:thetvdbid completionHandler:^(NSDictionary *result, NSError *error) {
                if (result) {
                    // Create the entity
                    serie = [Serie MR_createInContext:managedObjectContext];
                    [serie updateAttributes:result];
                    
                    // Update the Serie in Core Data
                    [result[@"episodes"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        @autoreleasepool {
                            Episode *ep = [Episode MR_createInContext:managedObjectContext];
                            [ep updateAttributes:obj];
                            [serie addEpisodesObject:ep];// Add the episode to the serie.
                        }
                    }];
                    
                    NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithDictionary:result];
                    [updates removeObjectForKey:@"episodes"];
                    
                    [serie updateAttributes:updates];
                    
                    // Save the changes
                    [managedObjectContext MR_saveToPersistentStoreWithCompletion:nil];
                    
                    // Update the UI.
                    [self updateShowInfo:serie];
                }
                
                if (error) {
                    NSLog(@"Error TheTVDB getShowWithEpisodeList:");
                    [self updateShowInfo:nil];
                    // NSLog(@"%@", error);
                }
                
                [self toggleLoading:NO];
            }];
        }
    }
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) {
        managedObjectContext = [NSManagedObjectContext MR_context];
    }
    
    return managedObjectContext;
}

#pragma mark - Private

- (void)toggleLoading:(BOOL)isLoading {
    if (isLoading) {
        [self.metadataBox setHidden:YES];
        [self.loadingText setHidden:NO];
        [self.spinner setHidden:NO];
        [self.spinner startAnimation:nil];
    } else {
        [self.metadataBox setHidden:NO];
        [self.loadingText setHidden:YES];
        [self.spinner setHidden:YES];
        [self.spinner stopAnimation:nil];
    }
    
}

- (void)updateShowInfo:(Serie *)serie {
    if (!serie) {
        [self.showName setStringValue:@""];
        [self.genre setStringValue:@""];
        [self.rating setIntegerValue:0];
        [self.showDescription setString:@""];
        [self.showYear setStringValue:@""];
        [self.showDuration setStringValue:@""];
        return;
    }
    
    // Get the poster
    [TheTVDB getPosterForShow:serie completionHandler:^(NSImage *poster, NSNumber *showID) {
        NSNumber *selectedObjectID = [[[self.showsArrayController selectedObjects] firstObject] objectForKey:@"tvdb_id"];
        
        // Only set the poster if the selected item id is equal to poster id.
        if ([selectedObjectID isEqualToNumber:showID])
            [self.showPoster setImage:poster];
    }];
    
//    NSImage *ea = [NSImage imageNamed:@"ea"];
//    [self.studioLogo setImage:ea];
    
    [self.showName setStringValue:(serie.name ?: @"")];
    [self.genre setStringValue:(serie.genre ?: @"")];
    [self.rating setDoubleValue:[serie.rating doubleValue]];// if rating is null doubleValue will return 0.
    [self.showDescription setString:(serie.seriesDescription ?: @"Description not avaible!")];
    
    NSString *runtime = (serie.runtime ? [[serie.runtime stringValue] stringByAppendingString:@" Min"] : @"");
    [self.showDuration setStringValue:runtime];
    
    //FIXME: crash when the serie is new to the database.
    //NSArray *episodes = [serie.episodes allObjects];
    //[self.episodesArrayController addObjects:episodes];
    
    if (serie.started) {
        NSInteger year = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:serie.started] year];
        [self.showYear setStringValue:[NSString stringWithFormat:@"%ld", year]];
    } else {
        [self.showYear setStringValue:@""];
    }
    
    // Disable subscribe button if already subscribed.
    if ([self userIsSubscribedToShow:serie]) {
        [self.subscribeButton setEnabled:NO];
        [self.subscribeButton setTitle:@"Subscribed"];
    } else {
        [self.subscribeButton setEnabled:YES];
        [self.subscribeButton setTitle:@"Subscribe"];
    }
}

- (void)resetShowView {
    [self.showName setStringValue:@""];
    [self.genre setStringValue:@""];
    [self.rating setIntegerValue:0];
    [self.showDescription setString:@""];
    [self.showYear setStringValue:@""];
    [self.showDuration setStringValue:@""];
    [self.showPoster setImage:[NSImage imageNamed:@"posterArtPlaceholder"]];
    //[self.studioLogo setImage:nil];
}

- (BOOL)userIsSubscribedToShow:(Serie *)serie {
    NSArray *subs = [Subscription MR_findByAttribute:@"serie" withValue:serie inContext:self.managedObjectContext];
    return subs.count;
}

@end
