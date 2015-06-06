//
//  NSMutableDictionary+Extensions.m
//  TVShows
//
//  Created by Lucas on 31/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "NSMutableDictionary+Extensions.h"

@implementation NSMutableDictionary (Extensions)

- (void)setObjectIfNotNull:(id)anObject forKey:(id <NSCopying>)aKey {
    if (anObject != nil && anObject != [NSNull null])
        [self setObject:anObject forKey:aKey];
}

@end
