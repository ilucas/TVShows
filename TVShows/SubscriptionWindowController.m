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

#import "SubscriptionWindowController.h"
#import "MetadataViewController.h"
#import "TheTVDB.h"
#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

@interface SubscriptionWindowController () <MetadataViewDelegate>

@property (assign) BOOL isLoading;

#pragma mark - Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Bindings
@property (strong, nonatomic) NSArray *sorter;

@end

@implementation SubscriptionWindowController
@synthesize managedObjectContext;

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithWindowNibName:@"SubscriptionWindowController"];
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        self.showList = [NSMutableArray array];
        self.episodesList = [NSMutableArray array];
        self.sorter = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
        
        self.managedObjectContext = [NSManagedObjectContext context];
        
        self.isLoading = false;
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
        TVDBSerie *selectedObject = [self selectedShow];
        Serie *serie = [Serie findFirstByAttribute:@"serieID" withValue:selectedObject.serieID inContext:localContext];
        
        Subscription *subscription = [Subscription createEntityInContext:localContext];
        [subscription setIsEnabledValue:YES];
        [subscription setQuality:@""];
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

- (IBAction)search:(id)sender {
    NSString *search = self.searchField.stringValue;
    
    if ([search isEmpty]) {
        [self.showList removeAllObjects];
        [self.showsTableView reloadData];
        return;
    }
    
    [[TVDBManager manager] searchSerie:search completionBlock:^(NSArray<TVDBSerie *> * _Nonnull series) {
        [self.showList removeAllObjects];
        [self.showList addObjectsFromArray:series];
        [self.showsTableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        
        if (response.statusCode != 404) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.window completionHandler:nil];
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
        }
    }];
}

#pragma mark - NSWindowDelegate

- (void)windowDidLoad {
    if (![[TVDBManager manager] token]) {
        [[TVDBManager manager] requestToken];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.showList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    TVDBSerie __weak *serie = self.showList[row];
    return serie.name;
}

- (TVDBSerie *)selectedShow {
    NSInteger selectedRow = self.showsTableView.selectedRow;
    
    if (selectedRow < 0) {
        return nil;
    }
    
    return self.showList[selectedRow];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.showList.count <= 0) return;
    
    TVDBSerie *selectedObject = [self selectedShow];
    
    [self.metadataViewController resetView];
    
    if (selectedObject) {
        // download serie info.
        [self.metadataViewController toggleLoading:YES];
        
        [[TVDBManager manager] serie:selectedObject.serieID completionBlock:^(TVDBSerie * _Nonnull tvdbSerie) {
            NSManagedObjectContext *localContext = [NSManagedObjectContext contextWithParent:managedObjectContext];
            
            SerieID __block *serieID;
            
            [localContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                NSError *error;
                Serie *serie = [tvdbSerie insertManagedObjectIntoContext:localContext error:&error];
                serieID = serie.objectID;
                
                if (error) {
                    DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
                }
            } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                if (error) {
                    NSAlert *alert = [NSAlert alertWithError:error];
                    [alert beginSheetModalForWindow:self.window completionHandler:nil];
                }
                
                // Update the UI.
                [self updateShowInfo:serieID];
            }];
            
            [self.metadataViewController toggleLoading:NO];
        } failure:^(NSError * _Nonnull error) {
            [self.metadataViewController toggleLoading:NO];
            [self updateShowInfo:nil];
            
            NSAlert *al = [NSAlert alertWithError:error];
            [al beginSheetModalForWindow:self.window completionHandler:nil];
        }];
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
    
    Serie *serie = [managedObjectContext objectWithID:serieID];
    
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serie = %@", @YES];
        count = [[Subscription numberOfEntitiesWithPredicate:predicate inContext:self.managedObjectContext] unsignedIntegerValue];
    }];
    
    return count;
}

@end
