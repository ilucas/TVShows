//
//  NSString+Extensions.m
//  Cocoa+Extensions
//
//  Created by Lucas Casteletti.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2014. All rights reserved.
//  Licensed under the New BSD License
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (BOOL)contains:(NSString *)aString{
    return ([self rangeOfString:aString].location != NSNotFound);
}

// FROM: Michael Waterfall's MWFeedParser
// https://github.com/mwaterfall/MWFeedParser/blob/master/Classes/NSString%2BHTML.h
- (NSString *)stringByRemovingNewLinesAndWhitespace {
	// Scanner
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    // Scan
	while (![scanner isAtEnd]) {
		// Get non new line or whitespace characters
		temp = nil;
		[scanner scanUpToCharactersFromSet:characterSet intoString:&temp];
		if (temp) [result appendString:temp];
        
		// Replace with a space
		if ([scanner scanCharactersFromSet:characterSet intoString:NULL]) {
			if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
				[result appendString:@" "];
		}
        
	}
    
	// Return
	NSString *retString = [NSString stringWithString:result];
    
	// Return
	return retString;
}

- (NSArray *)componentsSeparatedByWords{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSMutableArray __block *array = [NSMutableArray array];
    
    [regex enumerateMatchesInString:self
                            options:NSMatchingReportProgress
                              range:self.range
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result)
            [array addObject:[self substringWithRange:result.range]];
    }];
    
    return array;
}

- (BOOL)isEmpty {
    if(self.length == 0) { //string is empty or nil
        return YES;
    }
    
    if(![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return YES;
    }
    
    return NO;
}

- (NSRange)range{
    return NSMakeRange(0, self.length);
}

@end