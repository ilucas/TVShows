//
//  NSManagedObject+Attributes.h
//  TVShows
//
//  Created by Lucas on 30/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Attributes)

- (void)updateAttributes:(NSDictionary *)attributes;

@end
