//
//  SubscriptionWindowController.m
//  TVShows
//
//  Created by Lucas on 02/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "SubscriptionWindowController.h"

@interface SubscriptionWindowController ()

@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

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

#pragma mark - Actions

- (IBAction)reloadShowList:(id)sender {
    
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
}

#pragma mark - NSTableViewDelegate

#pragma mark - NSTableViewDataSource

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
