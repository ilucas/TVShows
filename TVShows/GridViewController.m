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

#import "GridViewController.h"

#import "OEGridView.h"
//#import "OEGridGameCell.h"
#import "GridViewSubscriptionItemCell.h"

#import "Serie.h"
#import "Subscription.h"
#import "SubscriptionDataSource.h"

@interface GridViewController ()

@property (weak) NSManagedObjectContext *context;
@property (weak) IBOutlet NSArrayController *subscriptions;

@end

@implementation GridViewController
@synthesize gridView;

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        self.context = [NSManagedObjectContext defaultContext];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGridView];
}

- (void)awakeFromNib {
    [self reloadData];
}

#pragma mark - Actions

- (void)reloadData {
    [self.subscriptions fetchWithRequest:nil merge:NO error:nil];
    [gridView reloadData];
}

- (void)saveAndReloadData {
    [self.context MR_saveWithOptions:MRSaveParentContexts completion:^(BOOL contextDidSave, NSError *error) {
        [self reloadData];
        
        if (error) {
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
        }
    }];
}

#pragma mark - IKImageBrowserDelegate

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index {
    if (index == 0) {
        [self performSegueWithIdentifier:@"SubscriptionSegue" sender:self];
        return;
    }
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event {
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser backgroundWasRightClickedWithEvent:(NSEvent *)event {
}

#pragma mark - IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view {
    NSArray __weak *arrangedObjects = self.subscriptions.arrangedObjects;
    return arrangedObjects.count + 1;
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index {
    if (index == 0) {// "New subscription" Item
        return [GridViewAddItem new];
    }
    
    NSArray __weak *arrangedObjects = self.subscriptions.arrangedObjects;
    return arrangedObjects[index - 1];
}

#pragma mark - OEGridViewMenuSource

- (NSMenu *)gridView:(OEGridView *)gridView menuForItemsAtIndexes:(NSIndexSet *)indexes {
    // Don't show menu to the "New subscription" Item.
    if (indexes.count == 1 && indexes.firstIndex == 0) return nil;
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    [menu addItemWithTitle:NSLocalizedString(@"Check for new episodes", nil) action:@selector(checkNewEpisodes:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    
    [menu addItemWithTitle:NSLocalizedString(@"Remove Subscription", nil) action:@selector(removeSubscription:) keyEquivalent:@""];
    
    NSMenu *qualityMenu = [[NSMenu alloc] init];
    [qualityMenu addItemWithTitle:@"480p" action:@selector(changeQuality:) keyEquivalent:@""];
    [qualityMenu addItemWithTitle:@"720p" action:@selector(changeQuality:) keyEquivalent:@""];
    [qualityMenu addItemWithTitle:@"1080p" action:@selector(changeQuality:) keyEquivalent:@""];
    
    if (indexes.count > 1) {// If ther's more then 1 item selected. add to the menu Enable and Disable.
        [menu addItemWithTitle:NSLocalizedString(@"Enable", nil) action:@selector(enableSubscription:) keyEquivalent:@""];
        [menu addItemWithTitle:NSLocalizedString(@"Disable", nil) action:@selector(disableSubscription:) keyEquivalent:@""];
    } else {
        Subscription *subscription = [self.subscriptions.arrangedObjects objectAtIndex:(indexes.lastIndex - 1)];
        
        // Quality
        [[qualityMenu itemWithTitle:subscription.quality] setState:NSOnState];
        
        if (subscription.isEnabledValue) {
            [menu addItemWithTitle:NSLocalizedString(@"Disable Subscription", nil) action:@selector(disableSubscription:) keyEquivalent:@""];
        } else {
            [menu addItemWithTitle:NSLocalizedString(@"Enable Subscription", nil) action:@selector(enableSubscription:) keyEquivalent:@""];
        }
    }
    
    NSMenuItem *quality = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quality", nil) action:nil keyEquivalent:@""];
    [quality setSubmenu:qualityMenu];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:quality];
    
    return menu;
}

#pragma mark - Menu Actions

- (void)checkNewEpisodes:(id)sender {
    NSArray<Subscription *> *subscriptions = [self selectedObjects];
    NSMutableArray<NSNumber *> *ids = [NSMutableArray arrayWithCapacity:subscriptions.count];
    
    [subscriptions enumerateObjectsUsingBlock:^(Subscription *obj, NSUInteger idx, BOOL *stop) {
        [ids addObject:obj.serie.serieID];
    }];
    
    NSDistributedNotificationCenter *distributedCenter = [NSDistributedNotificationCenter defaultCenter];
    [distributedCenter postNotificationName:@"TVShows.Notification.CheckNewEpisodes" object:nil userInfo:@{@"serieID": ids}];
}

- (void)removeSubscription:(id)sender {
    [self.context performBlock:^{
        NSArray<Subscription *> *selectedObjects = [self selectedObjects];
        
        [selectedObjects enumerateObjectsUsingBlock:^(Subscription *subscription, NSUInteger idx, BOOL *stop) {
            DDLogInfo(@"Deleting Subscription <%@ (%@)>", subscription.serie.name, subscription.serie.serieID);
            [self.context deleteObject:subscription];
        }];
        
        [self saveAndReloadData];
    }];
}

- (void)enableSubscription:(id)sender {
    [self.context performBlock:^{
        NSArray<Subscription *> *selectedObjects = [self selectedObjects];
        
        [selectedObjects enumerateObjectsUsingBlock:^(Subscription *subscription, NSUInteger idx, BOOL *stop) {
            DDLogInfo(@"Enabling Subscription <%@ (%@)>", subscription.serie.name, subscription.serie.serieID);
            [subscription setIsEnabled:@true];
        }];
        
        [self saveAndReloadData];
    }];
}

- (void)disableSubscription:(id)sender {
    [self.context performBlock:^{
        NSArray<Subscription *> *selectedObjects = [self selectedObjects];
        
        [selectedObjects enumerateObjectsUsingBlock:^(Subscription *subscription, NSUInteger idx, BOOL *stop) {
            DDLogInfo(@"Disabling Subscription <%@ (%@)>", subscription.serie.name, subscription.serie.serieID);
            [subscription setIsEnabled:@false];
        }];
        
        [self saveAndReloadData];
    }];
}

- (void)changeQuality:(NSMenuItem *)sender {
    NSString *quality = sender.title;
    
    [self.context performBlock:^{
        NSArray<Subscription *> *selectedObjects = [self selectedObjects];
        
        [selectedObjects enumerateObjectsUsingBlock:^(Subscription *subscription, NSUInteger idx, BOOL *stop) {
            DDLogInfo(@"Changing Subscription Quality <%@ (%@)> %@ → %@", subscription.serie.name, subscription.serie.serieID, subscription.quality, quality);
            [subscription setQuality:quality];
        }];
        
        [self saveAndReloadData];
    }];
}

#pragma mark - Private

- (void)setupGridView {
    [gridView setAllowsReordering:NO];
    [gridView setAnimates:YES];
    [gridView setDraggingDestinationDelegate:nil];
    [gridView setCellClass:[GridViewSubscriptionItemCell class]];
    [gridView setCellSize:defaultGridSize];
    [gridView reloadData];
}

- (NSArray<Subscription *> *)selectedObjects {
    NSMutableIndexSet *selectionIndexes = [[gridView selectionIndexes] mutableCopy];
    
    [selectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx == 0) return;
        [selectionIndexes removeIndex:idx];
        [selectionIndexes addIndex:(idx - 1)];
    }];
    
    return [self.subscriptions.arrangedObjects objectsAtIndexes:selectionIndexes];
}

@end
