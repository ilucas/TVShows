//
//  SubscriptionWindowController.m
//  TVShows
//
//  Created by Lucas on 02/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "SubscriptionWindowController.h"
#import "LoadingViewController.h"
#import "TVRage.h"
#import "Serie.h"

@interface SubscriptionWindowController ()

#pragma mark - Core Data
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Loading Overlay
@property (weak, nonatomic) IBOutlet LoadingViewController *loadingViewController;

#pragma mark - Bindings;
@property (strong) NSMutableArray *sorter;

- (void)toggleLoading:(BOOL)isLoading;
- (BOOL)userIsSubscribedToShow:(NSString*)showName;

@end

@implementation SubscriptionWindowController

#pragma mark - Lifecycle

- (void)awakeFromNib {
    
}

- (instancetype)init {
    return [self initWithWindowNibName:@"SubscriptionWindowController"];
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        _sorter = [NSMutableArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    }
    
    return self;
}

#pragma mark - Actions

- (IBAction)reloadShowList:(id)sender {
    // Start overlay
    TVRage *service = [TVRage sharedInstance];
    
    [service getShowListWithCompletionHandler:^(NSArray *results, NSError *error) {
        NSUInteger count = [results count];
        
        NSLog(@"Total :%ld", count);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    NSArray *series = [Serie MR_findByAttribute:@"name" withValue:obj[@"name"] inContext:localContext];
                    
                    /*
                     * If Serie already exists
                     */
                    if ([series count] < 1) {
                        Serie *serie = [Serie MR_createInContext:localContext];
                        [serie updateAttributes:obj];
                    }
                    
//                    dispatch_async(dispatch_get_main_queue(), ^(void){
//                        NSLog(@"Importing %ld of %ld", idx, count);
//                    });
                }];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"Done importing.");
            });
            
        });
    }];
}

- (IBAction)openMoreInfoURL:(id)sender {
    
}

- (IBAction)closeWindow:(id)sender {
    [self close];
}

- (IBAction)subscribeToShow:(id)sender {
    
    // Close window after subscribe to show.
    [self closeWindow:nil];
}

#pragma mark - NSWindowDelegate

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Check last update date
    
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSInteger idx = [self.showsTableView selectedRow];
    
    NSArray* selectedObjects = [self.showsArrayController selectedObjects];
    //NSLog(@"%@", [self.showsArrayController selection]);
    
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext ?: [NSManagedObjectContext MR_context];
}

#pragma mark - Private

- (void)toggleLoading:(BOOL)isLoading {
    
}

- (BOOL)userIsSubscribedToShow:(NSString*)showName {
    return false;
}

@end
