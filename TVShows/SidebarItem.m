//
//  SidebarItem.m
//  TVShows
//
//  Created by Lucas on 12/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "SidebarItem.h"

@interface SidebarItem ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation SidebarItem

#pragma mark - Lifecycle

+ (instancetype)sidebarItemWithName:(NSString *)name {
    return [[SidebarItem alloc] initWithName:name];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    self = [self init];
    
    if (self) {
        self.name = name;
    }
    
    return self;
}

- (void)addItem:(SidebarItem *)item {
    [self.items addObject:item];
}

- (NSArray *)getItems {
    return [self.items copy];
}

- (BOOL)isGroup {
    return (self.items.count > 0);
}

- (NSString*)description {
    return self.name;
}

@end
