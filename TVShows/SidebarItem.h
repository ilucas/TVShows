//
//  SidebarItem.h
//  TVShows
//
//  Created by Lucas on 12/04/15.
//  Copyright (c) 2015 Víctor Pimentel. All rights reserved.
//

@import Cocoa;

@interface SidebarItem : NSObject

@property (nonatomic, copy) NSString *name;

+ (instancetype)sidebarItemWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;
- (void)addItem:(SidebarItem *)item;
- (NSArray *)getItems;
- (BOOL)isGroup;

@end
