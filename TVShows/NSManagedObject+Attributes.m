//
//  NSManagedObject+Attributes.m
//  TVShows
//
//  Created by Lucas on 30/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "NSManagedObject+Attributes.h"

@implementation NSManagedObject (Attributes)

- (void)updateAttributes:(NSDictionary *)attributes {
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // Check if key exists and is empty.
        if ([self respondsToSelector:NSSelectorFromString((NSString *)key)] && ![self valueForKey:key]) {
            [self setValue:obj forKey:key];
        }
    }];
}

@end
