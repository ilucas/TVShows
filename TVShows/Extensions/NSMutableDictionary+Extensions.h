//
//  NSMutableDictionary+Extensions.h
//  TVShows
//
//  Created by Lucas on 31/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Foundation;

@interface NSMutableDictionary (Extensions)

- (void)addObject:(id)anObject key:(id <NSCopying>)aKey;
@end
