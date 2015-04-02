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

#import <Cocoa/Cocoa.h>

#import "LROverflowButton.h"
#import "LRFilterButton.h"


@interface LRFilterBar : NSView {
	
	int buttonX;
	int xCoordinateOfViews;
	
	LROverflowButton *overflowButton;
	NSMenu *overflowMenu;
	
	NSArray *originalArray;
	SEL originalSelector;
	id originalSender;
	
	NSMutableArray *buttonsDictionary;
	
	double osVersion;
	BOOL retrievedOSVersion;
	
	// Coloring
	NSString *topColor;
	NSString *bottomColor;
	
	// Font Weight
	NSFont *fontWeight;
}

#pragma mark Drawing
- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)rect;
- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize;

#pragma mark Add Button
- (void)addItemsWithTitles:(NSArray *)array
			  withSelector:(SEL)selector
				withTarget:(id)target;
- (void)_addItemsWithTitles:(NSArray *)array
			  withSelector:(SEL)selector
				withTarget:(id)target;
- (void)addButtonWithTitle:(NSString *)title;
- (LRFilterButton *)createButtonWithTitle:(NSString *)title;
- (void) addDivider;

#pragma mark Remove All
- (void)removeAllItems; // Kevin O. of CoolMacSoftware

#pragma mark Overflow Menu
- (void)createOverflowMenu;

#pragma mark Button Action
- (void)performActionForButton:(id)button;

#pragma mark Deselect
- (void)deselectAllButtonsExcept:(id)button;

#pragma mark Operating System
- (double)getOSVersion;

#pragma mark Accessor Methods
- (NSString *)getSelectedTitleInSegment:(int)seg;
- (int)getSelectedIndexInSegment:(int)seg;  // Kevin O. of CoolMacSoftware
- (void)selectTitle:(NSString *)title
				inSegment:(int)seg;
- (void)selectIndex:(int)index
				inSegment:(int)seg;

#pragma mark Coloring
- (NSColor *)createColor:(NSString *)string;
- (NSColor *)topColor;
- (NSColor *)bottomColor;
- (void)setBlueBackground;
- (void)setGrayBackground;

#pragma mark Font Weight
- (NSFont *)fontWeight;
- (void)setRegularFontWeight;
- (void)setBoldFontWeight;

@end
