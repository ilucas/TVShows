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

@import Foundation;

@interface NSString (Extensions)

@property (readonly) NSRange range;

- (BOOL)contains:(NSString *)aString;

// Remove newlines and white space from string
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSArray *)componentsSeparatedByWords;
- (NSString *)stringByTrimmingWhitespaces;
- (BOOL)isEmpty;

@end