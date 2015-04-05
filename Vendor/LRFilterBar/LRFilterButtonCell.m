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

#import "LRFilterButtonCell.h"


@implementation LRFilterButtonCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSString *stringValue = [self title];
	NSFont *font = [self font];
	NSColor *textColor;
	
	if( [self state] == NSOnState ||
		_bcFlags2.mouseInside ) {
		
		[super drawBezelWithFrame:cellFrame inView:controlView];
		textColor = [NSColor whiteColor];
		
	} else {
		textColor = [NSColor blackColor];
	}
	
	cellFrame.origin.x += 7;
	cellFrame.origin.y += 2;

	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,textColor,NSForegroundColorAttributeName,nil]; 
	[stringValue drawInRect:cellFrame withAttributes:attributes];
}

@end
