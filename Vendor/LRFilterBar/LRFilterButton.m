/*
 Copyright (c) 2006-2007 by Logan Rockmore Design, http://www.loganrockmore.com/
 
 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "LRFilterButton.h"
#import "LRFilterButtonCell.h"

@implementation LRFilterButton

- (id)initWithOS:(double)osVersion
	  fontWeight:(NSFont *)fontWeight {
	  
	self = [super init];
	if (self != nil) {
		
        [self setCell:[[NSClassFromString(@"LRFilterButtonCell") alloc] init]];
        
        [self setBezelStyle:NSRecessedBezelStyle];
        
		[self setButtonType:NSPushOnPushOffButton];
		[self setFont:fontWeight];
	}
	return self;
}

@end
