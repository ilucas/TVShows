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

#import "LRFilterBar.h"

#define kLeftMargin 7
#define kSpacing 2

@implementation LRFilterBar


#pragma mark Drawing

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {

		buttonX = kLeftMargin;

		// Create Button Arrays
		buttonsDictionary = [[NSMutableArray alloc] init];
		[buttonsDictionary addObject:[[NSMutableArray alloc] init]];

		// Create Overflow Button
		overflowButton = [[LROverflowButton alloc] init];
		[overflowButton setTarget:self];
		
		// Create Colors
		topColor = [[NSString alloc] init];
		bottomColor = [[NSString alloc] init];
		
		// Set Default Color
		[self setGrayBackground];
		
		// Set Default Font
		[self setBoldFontWeight];
		
	}

	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSColor *topColorCopy = [self createColor:topColor];
	NSColor *bottomColorCopy = [self createColor:bottomColor];
	
	// Draw Background Gradient
	if( topColorCopy && bottomColorCopy ) {
        NSGradient *aGradient = [[NSGradient alloc] initWithStartingColor:topColorCopy
                                                               endingColor:bottomColorCopy];
        [aGradient drawInRect:rect angle:90];
	}
	
	// Draw Bottom Line
	[[NSColor blackColor] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0,0) toPoint:NSMakePoint( rect.size.width ,0)];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
	NSMutableArray *selectedTitleArray = [[NSMutableArray alloc] init];
	
	NSEnumerator *dictEnumerator = [buttonsDictionary objectEnumerator];
	id dictObject;
	
	while( (dictObject = [dictEnumerator nextObject]) ) {
		
		// Save Old Selected Button
		NSEnumerator *enumerator = [dictObject objectEnumerator];
		id object;
		
		while ( (object = [enumerator nextObject]) ) {
			if( [object state] == NSOnState )
				[selectedTitleArray addObject:[object title]];
		}
		
		// Remove Old Buttons
		enumerator = [dictObject objectEnumerator];
		
		while ( (object = [enumerator nextObject]) ) {
			if( [object class] != [NSMenuItem class] )
				[object removeFromSuperview];
		}
		
		[dictObject removeAllObjects];
		
		buttonX = kLeftMargin;
		
		// Remove Overflow Button
		if( overflowButton ) {
			[overflowButton removeFromSuperview];
			overflowMenu = nil;
		}
	}
	
	[buttonsDictionary removeAllObjects];
	[buttonsDictionary addObject:[[NSMutableArray alloc] init]];
	
	// Add New Buttons
	if(originalArray != nil) // Kevin O. of CoolMacSoftware
		[self _addItemsWithTitles:originalArray withSelector:originalSelector withTarget:originalSender];
	
	dictEnumerator = [buttonsDictionary objectEnumerator];
	int i=0;
	
	while( (dictObject = [dictEnumerator nextObject]) ) {
		
		// Select Previous Button
		NSEnumerator *enumerator = [dictObject objectEnumerator];
		id object;
		
		NSButton *selectedButton = nil;
		while ( (object = [enumerator nextObject]) ) {
			if( [[object title] isEqualTo:[selectedTitleArray objectAtIndex:i]] ) {
				selectedButton = object;
				break;
			}
		}
		if( selectedButton )
			[selectedButton setState:NSOnState];
		
		i++;
	}
}


#pragma mark Add Button

- (void)addItemsWithTitles:(NSArray *)array
			  withSelector:(SEL)selector
				withTarget:(id)target
{
	[self _addItemsWithTitles:array withSelector:selector withTarget:target];
	
	NSEnumerator *dictEnumerator = [buttonsDictionary objectEnumerator];
	id dictObject;
	
	while( (dictObject = [dictEnumerator nextObject]) ) {
		
		[[dictObject objectAtIndex:0] setState:NSOnState];
	}
}

- (void)_addItemsWithTitles:(NSArray *)array
			  withSelector:(SEL)selector
				withTarget:(id)target
{	
	int i;
	for( i=0; i<[array count]; i++ ) {
		
		if( [[array objectAtIndex:i] isEqualTo:@"DIVIDER"] )
			[self addDivider];
		else	
			[self addButtonWithTitle:[array objectAtIndex:i]];
	}
	
	
	if( !originalArray ) {
		originalArray = [[NSArray alloc] initWithArray:array];
		originalSelector = selector;
		originalSender = target;
	}
}

- (void)addButtonWithTitle:(NSString *)title
{
	LRFilterButton *newButton = [self createButtonWithTitle:title];
	
	[newButton setAction:@selector(performActionForButton:)];
	[newButton setTarget:self];
	
	// Set X,Y Coordinates
	int buttonHeight = [newButton frame].size.height;
	int viewHeight = [self frame].size.height;
	int buttonYCoordinate = (viewHeight-buttonHeight) / 2;
	
	int buttonXCoordinate = buttonX;
	
	[newButton setFrameOrigin:NSMakePoint(buttonXCoordinate,buttonYCoordinate)];
	
	// Increment the X Offset For Next Button
	buttonX += [newButton frame].size.width + kSpacing;
	
	// Add To View
	if( buttonX < [self frame].size.width - [overflowButton frame].size.width ) {
		
		[self addSubview:newButton];
		
		id tempArray = [buttonsDictionary objectAtIndex:[buttonsDictionary count]-1];
		[tempArray addObject:newButton];
		
		[newButton setShowsBorderOnlyWhileMouseInside:YES];
		
	} else {
		
		if( !overflowMenu )
			[self createOverflowMenu];
		
		NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(performActionForButton:) keyEquivalent:@""];
		[newMenuItem setTarget:self];
		[overflowMenu addItem:newMenuItem];
		
		id tempArray = [buttonsDictionary objectAtIndex:[buttonsDictionary count]-1];
		[tempArray addObject:newMenuItem];
	}
}

- (LRFilterButton *)createButtonWithTitle:(NSString *)title
{
	// Create Button
	LRFilterButton *newButton = [[LRFilterButton alloc] initWithOS:[self getOSVersion] fontWeight:[self fontWeight]];
	[newButton setTitle:title];
	[newButton sizeToFit];
	
	return newButton;
}

- (void) addDivider
{
	if( buttonX < [self frame].size.width - [overflowButton frame].size.width ) {
		
		buttonX += 3;
		
		NSButton *newButton = [[NSButton alloc] init];
		[newButton setImage:[[NSImage alloc] initByReferencingFile:
                                   [[NSBundle bundleForClass:[self class]] pathForResource:@"OverflowDivider"
                                                                                    ofType:@"png"]]];
		[newButton setBordered:NO];
		[newButton sizeToFit];
		
		// Set X,Y Coordinates
		int buttonHeight = [newButton frame].size.height;
		int viewHeight = [self frame].size.height;
		int buttonYCoordinate = (viewHeight-buttonHeight) / 2;
		
		int buttonXCoordinate = buttonX;
		
		[newButton setFrameOrigin:NSMakePoint(buttonXCoordinate,buttonYCoordinate)];
		
		// Increment the X Offset For Next Button
		buttonX += [newButton frame].size.width + 3 + kSpacing;
		
		// Add To View
		[self addSubview:newButton];
		
		id tempArray = [buttonsDictionary objectAtIndex:[buttonsDictionary count]-1];
		[tempArray addObject:newButton];
		
	} else {
		
		if( !overflowMenu )
			[self createOverflowMenu];
		
		NSMenuItem *newMenuItem = [NSMenuItem separatorItem];
		[overflowMenu addItem:newMenuItem];
		
		id tempArray = [buttonsDictionary objectAtIndex:[buttonsDictionary count]-1];
		[tempArray addObject:newMenuItem];
		
	}
	
	[buttonsDictionary addObject:[[NSMutableArray alloc] init]];
}


#pragma mark Remove All

- (void)removeAllItems // Kevin O. of CoolMacSoftware
{	
	NSEnumerator *dictEnumerator = [buttonsDictionary objectEnumerator];
	id dictObject;
	
	while( (dictObject = [dictEnumerator nextObject]) ) {
		
		// Remove Old Buttons
		NSEnumerator *enumerator = [dictObject objectEnumerator];
		id object;
		
		while ( (object = [enumerator nextObject]) ) {
			
			if( [object class] != [NSMenuItem class] )
				[object removeFromSuperview];
		}
		
		[dictObject removeAllObjects];
		
		// Remove Overflow Button
		if( overflowButton ) {
			[overflowButton removeFromSuperview];
			overflowMenu = nil;
		}
	}
	
	[buttonsDictionary removeAllObjects];
	[buttonsDictionary addObject:[[NSMutableArray alloc] init]];
	originalArray = nil;
	originalSelector = nil;
	originalSender = nil;
	buttonX = kLeftMargin;
}

#pragma mark Overflow Menu

- (void)createOverflowMenu
{
	// Create Menu
	overflowMenu = [[NSMenu alloc] init];
	[overflowButton setMenu:overflowMenu];
	
	// Set X,Y Coordinates
	int buttonHeight = [overflowButton frame].size.height;
	int viewHeight = [self frame].size.height;
	int buttonWidth = [overflowButton frame].size.width;
	int viewWidth = [self frame].size.width;
	
	int buttonYCoordinate = (viewHeight-buttonHeight) / 2;
	int buttonXCoordinate = viewWidth-buttonWidth;
	
	[overflowButton setFrameOrigin:NSMakePoint(buttonXCoordinate,buttonYCoordinate)];
	
	// Add Subview Button
	[self addSubview:overflowButton];
}

#pragma mark Button Action

- (void)performActionForButton:(id)button
{
	[self deselectAllButtonsExcept:button];
	[originalSender performSelector:originalSelector];
}

#pragma mark Deselect

- (void)deselectAllButtonsExcept:(id)button
{
	NSEnumerator *dictEnumerator = [buttonsDictionary objectEnumerator];
	id dictObject;
	
	while( (dictObject = [dictEnumerator nextObject]) ) {
		
		if( [dictObject containsObject:button] ) {
			
			NSEnumerator *e = [dictObject objectEnumerator];
			id object;
			
			while ( (object = [e nextObject]) ) {
				if ( object != button )
					[object setState:NSOffState];
			}
			
			[button setState:NSOnState];
		}
	}
}

#pragma mark Operating System

- (double)getOSVersion
{
	if( retrievedOSVersion == YES )
		return osVersion;
	
	// Kevin O. of CoolMacSoftware
	NSString *osVersionString = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"];
	osVersion = [osVersionString doubleValue];
	
	retrievedOSVersion = YES;
	
	return osVersion;
}


#pragma mark Accessor Methods

- (NSString *)getSelectedTitleInSegment:(int)seg
{
	if( seg < [buttonsDictionary count] ) {
		NSEnumerator *e = [[buttonsDictionary objectAtIndex:seg] objectEnumerator];
		id object;
		
		while ( (object = [e nextObject]) ) {
			if( [object state] == NSOnState )
				return [object title];
		}
	}
	
	return @"";
}

- (int)getSelectedIndexInSegment:(int)seg  // Kevin O. of CoolMacSoftware
{
	int index = 0;
	
	if( seg < [buttonsDictionary count] ) {
		
		NSEnumerator *e = [[buttonsDictionary objectAtIndex:seg] objectEnumerator];
		id object;
		
		while ( (object = [e nextObject]) ) {
			if( [object state] == NSOnState )
				return index;
			index++;
		}
	}
	
	return -1;
}

- (void)selectTitle:(NSString *)title
				inSegment:(int)seg
{
	if( seg < [buttonsDictionary count] ) {
		NSEnumerator *e = [[buttonsDictionary objectAtIndex:seg] objectEnumerator];
		id object;
		
		while ( (object = [e nextObject]) ) {
			if( [[object title] isEqualTo:title] ) {
				
				[object setState:NSOnState];
				[self performActionForButton:object];
				return;
			}
		}
	}
}

- (void)selectIndex:(int)index
				inSegment:(int)seg
{
	if( index == -1 )
		return;
		
	if( seg < [buttonsDictionary count] ) {
		
		id object = [[buttonsDictionary objectAtIndex:seg] objectAtIndex:index];
		[self performActionForButton:object];
	}
}

#pragma mark Coloring

- (NSColor *)createColor:(NSString *)string
{
	if( string != nil ) {
		
		float red = 0.0;
		float green = 0.0;
		float blue = 0.0;
		float alpha = 1.0;
		
		NSScanner *scanner = [NSScanner scannerWithString:string];
		
		[scanner setScanLocation:25];
		[scanner scanFloat:&red];
		[scanner scanFloat:&green];
		[scanner scanFloat:&blue];
		[scanner scanFloat:&alpha];
		
		return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
	}
	
	return NULL;
}

- (NSColor *)topColor {		return [self createColor:topColor];		}
- (NSColor *)bottomColor {	return [self createColor:bottomColor];	}

- (void)setBlueBackground
{
	topColor = [[NSColor colorWithCalibratedRed:(182.0/255.0) green:(192.0/255.0) blue:(207.0/255.0) alpha:1.0] description];
	bottomColor = [[NSColor colorWithCalibratedRed:(203.0/255.0) green:(210.0/255.0) blue:(221.0/255.0) alpha:1.0] description];
	
	[self setNeedsDisplay:YES];
}

- (void)setGrayBackground
{
	topColor = [[NSColor colorWithCalibratedRed:(181.0/255.0) green:(181.0/255.0) blue:(181.0/255.0) alpha:1.0] description];
	bottomColor = [[NSColor colorWithCalibratedRed:(216.0/255.0) green:(216.0/255.0) blue:(216.0/255.0) alpha:1.0] description];
	
	[self setNeedsDisplay:YES];
}

#pragma mark Font Weight

- (NSFont *)fontWeight { return fontWeight; }

- (void)setRegularFontWeight
{
	fontWeight = [NSFont systemFontOfSize:11];
	
	[self resizeSubviewsWithOldSize:[self frame].size];
}

- (void)setBoldFontWeight
{
	fontWeight = [NSFont boldSystemFontOfSize:11];
	
	[self resizeSubviewsWithOldSize:[self frame].size];
}

@end
