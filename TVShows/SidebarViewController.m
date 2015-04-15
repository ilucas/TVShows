//
//  SidebarViewController.m
//  TVShows
//
//  Created by Lucas on 14/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "SidebarViewController.h"
#import "SidebarItem.h"

@interface SidebarViewController ()
@property (strong) NSMutableArray *array;
@end

@implementation SidebarViewController
@synthesize outlineView = _outlineView;

#pragma mark - Lifecycle

+(void)initialize {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.array = [[NSMutableArray alloc] init];
    
    SidebarItem *Shows = [[SidebarItem alloc] initWithName:@"Show list"];
    SidebarItem *subs = [[SidebarItem alloc] initWithName:@"Subscriptions"];
    
    
    SidebarItem *smart = [[SidebarItem alloc] initWithName:@"Collections"];
    [smart addItem:[SidebarItem sidebarItemWithName:@"Active"]];
    [smart addItem:[SidebarItem sidebarItemWithName:@"Canceled"]];
    [smart addItem:[SidebarItem sidebarItemWithName:@"Air Today"]];
    [smart addItem:[SidebarItem sidebarItemWithName:@"Recently Added"]];
    
    [self.array addObjectsFromArray:[NSArray arrayWithObjects:Shows, subs, smart, nil]];
    
    [_outlineView reloadData];
}

- (void)awakeFromNib {
}

#pragma mark - NSOutlineViewDelegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![item isGroup];
}

#pragma mark - NSOutlineViewDataSource

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
