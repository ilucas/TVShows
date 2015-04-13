//
//  AppDelegate.m
//  TVShows
//
//  Created by Lucas on 11/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "AppDelegate.h"
#import "SidebarItem.h"

@interface AppDelegate ()

    @property (weak) IBOutlet NSWindow *window;
    @property (weak) IBOutlet NSOutlineView *outilneView;
    @property (strong) NSMutableArray * array;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.array = [[NSMutableArray alloc] init];
        
        SidebarItem *Shows = [[SidebarItem alloc] initWithName:@"Show list"];
        SidebarItem *subs = [[SidebarItem alloc] initWithName:@"Subscriptions"];
        
        
        SidebarItem *smart = [[SidebarItem alloc] initWithName:@"Collections"];
        [smart addItem:[SidebarItem sidebarItemWithName:@"Active"]];
        [smart addItem:[SidebarItem sidebarItemWithName:@"Canceled"]];
        [smart addItem:[SidebarItem sidebarItemWithName:@"Air Today"]];
        [smart addItem:[SidebarItem sidebarItemWithName:@"Recently Added"]];
        
        [self.array addObjectsFromArray:[NSArray arrayWithObjects:Shows, subs, smart, nil]];
        
    }
    return self;
}

#pragma mark - NSOutlineViewDatasource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return !item ? self.array[index] : [item getItems][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return !item ? YES : [[item getItems] count] != 0;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return !item ? [self.array count] : [[item getItems] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return [item name];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *view;
    
    if ([item isGroup]) {
        view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        view.textField.stringValue = [item name];
    } else {
        view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        view.textField.stringValue = [item name];
    }
    
    return view;
}

@end
