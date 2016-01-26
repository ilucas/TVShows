//
//  NSDictionary+Extensions.m
//  TVShows
//
//  Created by Lucas on 10/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "NSDictionary+Extensions.h"

@implementation NSDictionary (Extensions)

- (id)objectForKeyOrNil:(id)key {
    id val = [self objectForKey:key];
    if ([val isEqual:[NSNull null]]) {
        return nil;
    }
    
    return val;
}

@end
