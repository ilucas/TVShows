//
//  SubscriptionWindowController.m
//  TVShows
//
//  Created by Lucas on 02/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "SubscriptionWindowController.h"
#import "MetadataViewController.h"
#import "TheTVDB.h"
#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

@interface SubscriptionWindowController () <MetadataViewDelegate>

#pragma mark - Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Bindings
@property (strong) NSMutableArray *sorter;
@property (readwrite, strong, nonatomic) NSMutableArray *showList;

- (BOOL)userIsSubscribedToShow:(Serie *)serie;
- (void)updateShowInfo:(SerieID *)serieID;
- (void)reset;
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
        
        managedObjectContext = [NSManagedObjectContext MR_context];
    }
    
    return self;
}

#pragma mark - IBActions

- (IBAction)openMoreInfoURL:(id)sender {

}

- (IBAction)closeWindow:(id)sender {
    [self reset];
    [self close];
}

- (IBAction)subscribeToShow:(id)sender {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSDictionary *selectedObject = [self selectedShow];
        Serie  *serie = [Serie MR_findFirstByAttribute:@"tvdb_id" withValue:selectedObject[@"tvdb_id"] inContext:localContext];
        
        Subscription *subscription = [Subscription MR_createEntityInContext:localContext];
        [subscription setIsEnabledValue:YES];
        [subscription setQualityValue:1.0];
        [subscription setSerie:serie];
    } completion:^(BOOL success, NSError *error) {
        if (success) {
            // Close window after subscribe to show.
            [self closeWindow:nil];
        } else {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.window completionHandler:nil];
        }
    }];
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
    
    if ([search isEmpty]) {
        [self.showList removeAllObjects];
        [self.showsTableView reloadData];
        return;
    }
    
    [[TheTVDB sharedInstance] searchShow:search completionHandler:^(NSArray *result, NSError *error) {
        if (result) {
            [self.showList removeAllObjects];
            [self.showList addObjectsFromArray:result];
            [self.showsTableView reloadData];
            
            // Select the first item in TableView if not empty.
            if (self.showList.count > 0)
                [self.showsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }
        
        if (error) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.window completionHandler:nil];
        }
    }];
}

#pragma mark - NSWindowDelegate

- (void)windowDidLoad {
    [super windowDidLoad];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.showList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[self.showList objectAtIndex:row] objectForKey:@"name"];
}

- (NSDictionary  *)selectedShow {
    NSInteger selectedRow = self.showsTableView.selectedRow;
    
    if (selectedRow < 0) {
        return nil;
    }
    
    return [self.showList objectAtIndex:selectedRow];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.showList.count <= 0) return;
    
    NSDictionary __block *selectedObject = [self selectedShow];
    
    [self.metadataViewController resetView];
    
    if (selectedObject) {
        NSNumber *thetvdbid = selectedObject[@"tvdb_id"];
        Serie __block *serie = [Serie MR_findFirstByAttribute:@"tvdb_id" withValue:thetvdbid inContext:self.managedObjectContext];
        
        // download serie info if is not already cached
        if (serie) {
            [self.metadataViewController toggleLoading:NO];
            [self updateShowInfo:serie.objectID];
        } else {
            [self.metadataViewController toggleLoading:YES];
            
            [[TheTVDB sharedInstance] getShowWithEpisodeList:thetvdbid completionHandler:^(NSDictionary *result, NSError *error) {
                if (result) {
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextWithParent:managedObjectContext];
                    
                    [localContext performBlock:^{
                        // Create the entity
                        serie = [Serie MR_createEntityInContext:localContext];
                        [serie updateAttributes:result];
                        
                        // Update the Serie in Core Data
                        [result[@"episodes"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            @autoreleasepool {
                                Episode *ep = [Episode MR_createEntityInContext:localContext];
                                [ep updateAttributes:obj];
                                [serie addEpisodesObject:ep];// Add the episode to the serie.
                            }
                        }];
                        
                        NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithDictionary:result];
                        [updates removeObjectForKey:@"episodes"];
                         
                        [serie updateAttributes:updates];
                        
                        // Save the changes
                        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                            if (success) {
                                // Update the UI.
                                [self updateShowInfo:serie.objectID];
                            }
                            
                            if (error) {
                                NSAlert *alert = [NSAlert alertWithError:error];
                                [alert beginSheetModalForWindow:self.window completionHandler:nil];
                            }
                        }];
                    }];
                }
                
                if (error) {
                    NSAlert *al = [NSAlert alertWithError:error];
                    [al beginSheetModalForWindow:self.window completionHandler:nil];
                    [self updateShowInfo:nil];
                }
                
                [self.metadataViewController toggleLoading:NO];
            }];
        }
    }
}

#pragma mark - Private

- (void)updateShowInfo:(SerieID *)serieID {

    if (!serieID) {
        
        // Empty the episodes table view
        [self.episodesList removeAllObjects];
        [self.episodesTableView reloadData];
        
        return;
    }
    
    Serie * serie = [managedObjectContext objectWithID:serieID];
    
    [self.metadataViewController updateShowInfo:serie];

    
    // Disable subscribe button if already subscribed.
    if ([self userIsSubscribedToShow:serie]) {
        [self.subscribeButton setEnabled:NO];
        [self.subscribeButton setTitle:@"Subscribed"];
    } else {
        [self.subscribeButton setEnabled:YES];
        [self.subscribeButton setTitle:@"Subscribe"];
    }
}

- (void)reset {
    [self.metadataViewController resetView];
    
    //Clean the search field
    [self.searchField setStringValue:@""];
    
    //Empty the series tableview
    [self.showList removeAllObjects];
    [self.showsTableView reloadData];
}

- (BOOL)userIsSubscribedToShow:(Serie *)serie {
    NSUInteger __block count;
    
    [self.managedObjectContext performBlockAndWait:^{
        count = [Subscription numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"serie = %@", @YES] inContext:self.managedObjectContext]
    }];
    
    return count;
}

@end
