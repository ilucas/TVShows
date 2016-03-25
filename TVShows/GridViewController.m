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

#pragma mark - IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view {
    NSArray __weak *arrangedObjects = self.subscriptions.arrangedObjects;
    return arrangedObjects.count;
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index {
    NSArray __weak *arrangedObjects = self.subscriptions.arrangedObjects;
    return arrangedObjects[index];
}

#pragma mark - Setup stuff

- (void)setupGridView {
    [gridView setAllowsReordering:NO];
    [gridView setAnimates:YES];
    [gridView setDraggingDestinationDelegate:nil];
    [gridView setCellClass:[OEGridGameCell class]];
    [gridView setCellSize:defaultGridSize];
    [gridView reloadData];
}

@end
