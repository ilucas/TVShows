//
//  NSString+Extensions.h
//  Cocoa+Extensions
//
//  Created by Lucas Casteletti.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2014. All rights reserved.
//  Licensed under the New BSD License
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

- (BOOL)contains:(NSString *)aString;

// Remove newlines and white space from string
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSArray *)componentsSeparatedByWords;
- (BOOL)isEmpty;

- (NSRange)range;

@end