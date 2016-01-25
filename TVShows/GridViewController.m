//
//  GridViewController.m
//  TVShows
//
//  Created by Lucas Casteletti on 1/24/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

#import "GridViewController.h"

#import "OEGridView.h"
#import "OEGridGameCell.h"

#import "Serie.h"
#import "Subscription.h"
#import "SubscriptionDataSource.h"

@interface GridViewController ()

@property (strong) NSMutableArray *items;

@property (strong) NSManagedObjectContext *context;

@end

@implementation GridViewController
@synthesize gridView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray new];
    self.context = [NSManagedObjectContext context];
    
    [gridView setAllowsReordering:YES];
    [gridView setAnimates:YES];
    [gridView setDraggingDestinationDelegate:nil];
    [gridView setCellClass:[OEGridGameCell class]];
    [gridView setCellSize:defaultGridSize];
    
    [self.items addObjectsFromArray:[Subscription findAllInContext:self.context]];
    
    [gridView reloadData];
    
    [self stuff];
}


- (void)stuff {
    NSArrayController *ac = [[NSArrayController alloc] init];
    
    [ac setManagedObjectContext:self.context];
    [ac setEntityName:[Subscription entityName]];
    
//    [ac fetchWithRequest:nil merge:NO error:nil];
//    
//    NSLog(@"%@", [ac arrangedObjects]);
    
}

- (void)reloadData {
    NSLog(@"data realod");
}

#pragma mark - IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view {
    return self.items.count;
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index {
    return self.items[index];
}

@end
