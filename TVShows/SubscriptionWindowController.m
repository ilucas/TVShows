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
#import "TheTVDB.h"
#import "Serie.h"
#import "Episode.h"

@interface SubscriptionWindowController ()

#pragma mark - Core Data
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Loading Overlay
@property (weak, nonatomic) IBOutlet LoadingViewController *loadingViewController;

#pragma mark - Bindings
@property (strong) NSMutableArray *sorter;

- (void)toggleLoading:(BOOL)isLoading;
- (BOOL)userIsSubscribedToShow:(NSString*)showName;

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
        _sorter = [NSMutableArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    }
    
    return self;
}

#pragma mark - Actions

- (IBAction)reloadShowList:(id)sender {
    TVRage *service = [TVRage sharedInstance];
    
    [service getShowListWithCompletionHandler:^(NSArray *results, NSError *error) {
        NSUInteger count = [results count];
        
        NSLog(@"Total :%ld", count);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                [localContext setUndoManager:nil];
                
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
                        NSLog(@"Importing %ld of %ld", idx, count);
                        // });
                    }
                }];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"Done importing.");
                [self.managedObjectContext reset];
                [self.showsArrayController fetch:self];
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
    __block Serie *selectedObject = [[self.showsArrayController selectedObjects] firstObject];
    
    if (selectedObject) {
        // If the show information isn't complete, download the information
        if (selectedObject.isComplete) {
            [self toggleLoading:NO];
            [self updateShowInfo:selectedObject];
        } else {
            [self toggleLoading:YES];
            NSString *serie = [selectedObject name];
            
            [[TheTVDB sharedInstance] getShowWithEpisodeList:serie completionHandler:^(NSDictionary *result, NSError *error) {
                if (result) {
                    // Update the Serie in Core Data
                    [result[@"episodes"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        @autoreleasepool {
                            Episode *ep = [Episode MR_createInContext:managedObjectContext];
                            [ep updateAttributes:obj];
                            
                            [selectedObject addEpisodesObject:ep];// Add the episode to the serie.
                        }
                    }];
                    
                    NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithDictionary:result];
                    [updates removeObjectForKey:@"episodes"];
                    
                    [selectedObject updateAttributes:updates];
                    
                    // Save the changes
                    [managedObjectContext MR_saveToPersistentStoreWithCompletion:nil];
                    
                    // Update the UI.
                    [self updateShowInfo:selectedObject];
                }
                
                if (error) {
                    NSLog(@"Error TheTVDB getShowWithEpisodeList:");
                    [self updateShowInfo:nil];
//                    NSLog(@"%@", error);
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
    // do something when theres no value.
    
    if (!serie) {
        [self.showName setStringValue:@""];
        [self.genre setStringValue:@""];
        [self.rating setIntegerValue:0];
        [self.showDescription setString:@""];
        [self.showYear setStringValue:@""];
        [self.showDuration setStringValue:@""];
        return;
    }
    
    NSImage *ea = [NSImage imageNamed:@"ea"];
    
    [self.studioLogo setImage:ea];
    
    [self.showName setStringValue:(serie.name ?: @"")];
    [self.genre setStringValue:(serie.genre ?: @"")];
    [self.rating setDoubleValue:[serie.rating doubleValue]];// if rating is null doubleValue will return 0.
    [self.showDescription setString:(serie.seriesDescription ?: @"Description not avaible!")];
    
    NSString *runtime = (serie.runtime ? [[serie.runtime stringValue] stringByAppendingString:@" Min"] : @"");
    [self.showDuration setStringValue:runtime];
    
    if (serie.started) {
        NSInteger year = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:serie.started] year];
        [self.showYear setStringValue:[NSString stringWithFormat:@"%ld", year]];
    } else {
        [self.showYear setStringValue:@""];
    }
}

- (BOOL)userIsSubscribedToShow:(NSString*)showName {
    return false;
}

@end
