//
//  ESScroller.m
//  ScrollBar
//
//  Created by Jonathan on 13/04/2008.
//  Copyright 2008 EspressoSoft. All rights reserved.
//

#import "ESScroller.h"

#define ESScrollerKnobStrokeWidth 1.2
#define ESScrollerCornerXRadius [self isVertical] ? 6 : 6
#define ESScrollerCornerYRadius [self isVertical] ? 6 : 6
#define ESScrollerArrowHalfWidth 3.4
#define ESScrollerArrowHeight 5.3

enum {
	ESScrollerArrowsDoubleMax = 0,
	ESScrollerArrowsSingle = 1,
};
typedef NSUInteger ESScrollerArrowsSetting;

@interface ESScroller ()
@property(retain) NSGradient *foregroundWindowArrowBackgroundGradient;
@property(retain) NSGradient *backgroundWindowArrowBackgroundGradient;
@property(retain) NSGradient *foregroundWindowKnobGradient;
@property(retain) NSGradient *backgroundWindowKnobGradient;
@property(retain) NSGradient *knobSlotGradient;
@property(retain) NSGradient *arrowGradient;
@property(retain) NSGradient *backgroundWindowArrowGradient;
@property(retain) NSColor *foregroundWindowBoundaryColor;
@property(retain) NSColor *backgroundWindowBoundaryColor;
@end

@interface ESScroller (Private)
- (ESScrollerArrowsSetting)arrowsSetting;
- (void)drawArrowBackgroundEdgeForRect:(NSRect)rect highlight:(BOOL)highlight;
- (void)drawDividerHighlight:(BOOL)highlight;
- (void)drawArrowInRect:(NSRect)rect withTransform:(NSAffineTransform *)transform;
- (void)drawTopSection;
- (void)drawCurvedSocketForArrow:(NSScrollerArrow)whichArrow inRect:(NSRect)frame transform:(NSAffineTransform *)transform highlight:(BOOL)highlight;
@end


@implementation ESScroller (Private)

// what arrow setting has the user selected. This determines a lot of drawing
- (ESScrollerArrowsSetting)arrowsSetting;
{
	NSString *defaultsSetting = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain] valueForKey:@"AppleScrollBarVariant"];
	if (defaultsSetting == @"Single") {
		return ESScrollerArrowsSingle;
	} else if (defaultsSetting == @"DoubleMax") {
		return ESScrollerArrowsDoubleMax;
	}
	NSRect decrementArrowFrame = [self rectForPart:NSScrollerDecrementLine]; // points up
	NSRect incrementArrowFrame = [self rectForPart:NSScrollerIncrementLine]; // points down
	ESScrollerArrowsSetting setting;
	if (decrementArrowFrame.origin.y + decrementArrowFrame.size.height == incrementArrowFrame.origin.y)
		setting = ESScrollerArrowsDoubleMax;
	else
		setting = ESScrollerArrowsSingle;
	return setting;
}

// Draws a line down the left edge of the rect containing the arrow button
- (void)drawArrowBackgroundEdgeForRect:(NSRect)rect highlight:(BOOL)highlight;
{
	NSBezierPath *edge = [NSBezierPath bezierPathWithRect:NSMakeRect(rect.origin.x + 0.5, rect.origin.y, 0, rect.size.height)];
	
	if (!highlight)
		[self.foregroundWindowBoundaryColor setStroke];
	else
		[self.backgroundWindowBoundaryColor setStroke]; // FIXME wrong color
	
	if ([[[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSActiveApplicationBundleIdentifier"] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
		[self.backgroundWindowBoundaryColor setStroke];
	[edge stroke];
}

// ESScrollerArrowsDoubleMax case, we need a separator between the arrows
- (void)drawDividerHighlight:(BOOL)highlight;
{
	NSRect frame = [self rectForPart:NSScrollerIncrementLine];
	frame.size.height = 0;
	frame.origin.y += 0.5;
	NSBezierPath *edge = [NSBezierPath bezierPathWithRect:frame];
	if (!highlight)
		[[NSColor colorWithCalibratedRed:0.663 green:0.663 blue:0.663 alpha:1.0] setStroke];
	else
		[[NSColor colorWithCalibratedRed:0.51 green:0.576 blue:0.675 alpha:1.0] setStroke];
	[edge stroke];
}

// the arrow itself is drawn in the passed rect, but facing down, so may need transforming
- (void)drawArrowInRect:(NSRect)rect withTransform:(NSAffineTransform *)transform;
{
	// vertices of the triangle
	NSPoint p1 = NSMakePoint(rect.size.width / 2.0 - ESScrollerArrowHalfWidth, rect.origin.y + 6);
	NSPoint p2 = NSMakePoint(rect.size.width / 2.0, p1.y + ESScrollerArrowHeight);
	NSPoint p3 = NSMakePoint(rect.size.width / 2.0 + ESScrollerArrowHalfWidth, p1.y);
	
	// Constructing the path
	NSBezierPath *triangle = [NSBezierPath bezierPath];
	[triangle moveToPoint:p1];
	[triangle lineToPoint:p2];
	[triangle lineToPoint:p3];
	[triangle closePath];
	
	[triangle transformUsingAffineTransform:transform];
	
	// Draw the path
	if (![[[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSApplicationBundleIdentifier"] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
		[self.backgroundWindowArrowGradient drawInBezierPath:triangle angle:0.0];
	else
		[self.arrowGradient drawInBezierPath:triangle angle:0.0];
}

// if ESScrollerArrowsDoubleMax, the top part that isn't a button is drawn
- (void)drawTopSection;
{
	NSRect frame = NSMakeRect(0, 0, 15, 6);
	[self.foregroundWindowArrowBackgroundGradient drawInRect:frame angle:0.0];
	[self drawArrowBackgroundEdgeForRect:frame highlight:NO];
	[self drawCurvedSocketForArrow:NSNotFound inRect:frame transform:[NSAffineTransform transform] highlight:NO];
	
	NSPoint p0,p1;
	p0 = NSMakePoint(frame.origin.x + 0.5, frame.origin.y + frame.size.height);
	p1 = NSMakePoint(p0.x, p0.y+8.5);
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:p0];
	[path lineToPoint:p1];
	
	[self.foregroundWindowBoundaryColor setStroke];
	
	[path stroke];
}

// by default this is drawn below the rect you send it, then it gets transformed.
- (void)drawCurvedSocketForArrow:(NSScrollerArrow)whichArrow inRect:(NSRect)frame transform:(NSAffineTransform *)transform highlight:(BOOL)highlight;
{
	NSBezierPath *curve = [NSBezierPath bezierPath];
	NSPoint leftCorner,curveStart,curveEnd,rightCorner;
	leftCorner = NSMakePoint(frame.origin.x - 0.5,frame.origin.y + frame.size.height - 3);
	rightCorner = NSMakePoint(frame.size.width + 0.5 ,leftCorner.y);
	
	curveStart = NSMakePoint(leftCorner.x,leftCorner.y + 13);
	curveEnd = NSMakePoint(frame.size.width + 0.5,curveStart.y);
	
	
	[curve moveToPoint:leftCorner];
	[curve lineToPoint:curveStart];
	[curve curveToPoint:curveEnd controlPoint1:leftCorner controlPoint2:rightCorner];
	[curve lineToPoint:rightCorner];
	[curve transformUsingAffineTransform:transform];
	
	
	if (![[[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSApplicationBundleIdentifier"] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
		[self.backgroundWindowArrowBackgroundGradient drawInBezierPath:curve angle:0.0];
	else if (!highlight)
		[self.foregroundWindowArrowBackgroundGradient drawInBezierPath:curve angle:0.0];
	else
		[self.foregroundWindowKnobGradient drawInBezierPath:curve angle:0.0];
	
	//stroke just the curve part
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:curveStart];
	[path curveToPoint:curveEnd controlPoint1:leftCorner controlPoint2:rightCorner];
	[[NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1.0] setStroke];
	[path transformUsingAffineTransform:transform];
	[path stroke];
	
	// stroke the left side of the shape (is clear why if this part is commented out)
	NSBezierPath *line = [NSBezierPath bezierPath];
	leftCorner.x += 0.8;
	curveStart.x += 0.8;
	curveStart.y -= 3;
	[line moveToPoint:leftCorner];
	[line lineToPoint:curveStart];
	
	if (whichArrow == NSScrollerIncrementArrow || (whichArrow == NSScrollerDecrementArrow && [self arrowsSetting] == ESScrollerArrowsDoubleMax))
		[transform translateXBy:frame.size.width yBy:0.0];
	
	[line transformUsingAffineTransform:transform];
	
	if (!highlight)
		[[NSColor colorWithCalibratedRed:0.55 green:0.55 blue:0.55 alpha:1.0] setStroke];
	else
		[[NSColor colorWithCalibratedRed:0.51 green:0.576 blue:0.675 alpha:1.0] setStroke];
	[line stroke];
}

@end

@implementation ESScroller
@synthesize foregroundWindowArrowBackgroundGradient =  _foregroundWindowArrowBackgroundGradient;
@synthesize backgroundWindowArrowBackgroundGradient =  _backgroundWindowArrowBackgroundGradient;
@synthesize foregroundWindowKnobGradient = _foregroundWindowKnobGradient;
@synthesize backgroundWindowKnobGradient = _backgroundWindowKnobGradient;
@synthesize knobSlotGradient = _knobSlotGradient;
@synthesize arrowGradient = _arrowGradient;
@synthesize backgroundWindowArrowGradient = _backgroundWindowArrowGradient;
@synthesize foregroundWindowBoundaryColor = _foregroundWindowBoundaryColor;
@synthesize backgroundWindowBoundaryColor = _backgroundWindowBoundaryColor;

- (id)initWithFrame:(NSRect)frame;
{
//	NSLog(@"%p %s",self,__func__);
	if (![super initWithFrame:frame])
		return nil;
	
	self.foregroundWindowArrowBackgroundGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:1.0],0.0,[NSColor colorWithCalibratedRed:0.671 green:0.671 blue:0.671 alpha:1.0],1.0,nil] autorelease];
	
	self.backgroundWindowArrowBackgroundGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.0],0.0,[NSColor colorWithCalibratedRed:0.64 green:0.64 blue:0.64 alpha:1.0],1.0,nil] autorelease];
	
	self.foregroundWindowKnobGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.604 green:0.663 blue:0.745 alpha:1.0],0.0,[NSColor colorWithCalibratedRed:0.373 green:0.447 blue:0.569 alpha:1.0],1.0,nil] autorelease];
	
	self.backgroundWindowKnobGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.89 green:0.89 blue:0.89 alpha:1.0],0.0,[NSColor colorWithCalibratedRed:0.684 green:0.688 blue:0.688 alpha:1.0],1.0,nil] autorelease];
	
	self.knobSlotGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.6 alpha:1.0],0.0,[NSColor colorWithCalibratedWhite:0.8 alpha:1.0],0.1,[NSColor colorWithCalibratedWhite:0.92 alpha:1.0],0.25,[NSColor colorWithCalibratedWhite:0.95 alpha:1.0],0.67,[NSColor colorWithCalibratedWhite:0.92 alpha:1.0],0.85,[NSColor colorWithCalibratedWhite:0.88 alpha:1.0],1.0,nil] autorelease];
	
	self.arrowGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.3 alpha:1.0],0.0,[NSColor colorWithCalibratedWhite:0.2 alpha:1.0],1.0,nil] autorelease];
	
	self.backgroundWindowArrowGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.4 alpha:1.0],0.0,[NSColor colorWithCalibratedWhite:0.45 alpha:1.0],1.0,nil] autorelease];
	
	self.foregroundWindowBoundaryColor = [NSColor colorWithCalibratedRed:0.663 green:0.663 blue:0.663 alpha:1.0];
	self.backgroundWindowBoundaryColor = [NSColor colorWithCalibratedRed:0.51 green:0.576 blue:0.675 alpha:1.0];
	
	return self;
}

- (void)dealloc;
{
	[self.foregroundWindowArrowBackgroundGradient release];
	[self.backgroundWindowArrowBackgroundGradient release];
	[self.foregroundWindowKnobGradient release];
	[self.backgroundWindowKnobGradient release];
	[self.knobSlotGradient release];
	[self.arrowGradient release];
	[self.backgroundWindowArrowGradient release];
	[self.foregroundWindowBoundaryColor release];
	[self.backgroundWindowBoundaryColor release];
	[super dealloc];
}

- (BOOL)isVertical;
{
	NSRect frame = [self frame];
	if (frame.size.width < frame.size.height)
		return YES;
	else
		return NO;
}

- (CGFloat)fillAngle;
{
	return [self isVertical] ? 0.0 : 90.0;
}

// draw each element in turn
- (void)drawRect:(NSRect)frame;
{
	// always draw slot
	[self drawKnobSlotInRect:[self rectForPart:NSScrollerKnobSlot] highlight:NO];
	
	// if the window is to small for the arrows and knob then return
	if ([self usableParts] == NSNoScrollerParts)
		return;
	
	NSScrollerPart hitPart = [self hitPart]; // hit parts are highlighted
	
	// case one, window is too small for knob, but large enough for arrows
	if ([self usableParts] == NSOnlyScrollerArrows) {
		[self drawArrow:NSScrollerIncrementArrow highlight:(hitPart == NSScrollerIncrementLine)];
		[self drawArrow:NSScrollerDecrementArrow highlight:(hitPart == NSScrollerDecrementLine)];
		if ([self arrowsSetting] == ESScrollerArrowsDoubleMax) { // both arrows at end
			[self drawDividerHighlight:(hitPart == NSScrollerIncrementLine || hitPart == NSScrollerDecrementLine)];
			[self drawTopSection];
		}
	}
	
	// case two, window is large enough for all
	if ([self usableParts] == NSAllScrollerParts) {
		[self drawArrow:NSScrollerIncrementArrow highlight:(hitPart == NSScrollerIncrementLine)];
		[self drawArrow:NSScrollerDecrementArrow highlight:(hitPart == NSScrollerDecrementLine)];
		if ([self arrowsSetting] == ESScrollerArrowsDoubleMax) {
			[self drawDividerHighlight:(hitPart == NSScrollerIncrementLine || hitPart == NSScrollerDecrementLine)];
			[self drawTopSection];
		}
		[self drawKnob];
	}
}

- (NSRect)rectForPart:(NSScrollerPart)partCode;
{
	NSRect frame = [super rectForPart:partCode];
	BOOL isVertical = [self isVertical];
	
	if (partCode == NSScrollerKnob) {
		frame.origin.y += isVertical ? 3.5 : 0.0; // reversed coordinate system the frame for the knob need tweaking a bit
		frame.origin.x += isVertical ? 1 : 0.7;
		frame.size.width -= isVertical ? 2.2 : 1.5;
		frame.size.height -= isVertical ? 4.5 : 0.0;
		
		if ([self arrowsSetting] == ESScrollerArrowsSingle) {
			frame.origin.y += isVertical ? 1.6 : 1.6; // more tweaking if the arrows are at either end
			frame.size.height -= isVertical ? 4 : 2;
		}
	}
	return frame;
}

- (void)drawArrow:(NSScrollerArrow)whichArrow highlight:(BOOL)highlight;
{
	NSRect frame;
	NSBezierPath *path;
	
	if (whichArrow == NSScrollerDecrementArrow)
		frame = [self rectForPart:NSScrollerDecrementLine];
	else
		frame = [self rectForPart:NSScrollerIncrementLine];
	
	path = [NSBezierPath bezierPathWithRect:frame];
	
	if (![[[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSApplicationBundleIdentifier"] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) // are we forground?
		[self.backgroundWindowArrowBackgroundGradient drawInBezierPath:path angle:[self fillAngle]];
	else if (!highlight)
		[self.foregroundWindowArrowBackgroundGradient drawInBezierPath:path angle:[self fillAngle]];
	else
		[self.foregroundWindowKnobGradient drawInBezierPath:path angle:[self fillAngle]]; // highlighted arrows have the same gradient as the knob
	
	
	
	
	
	if (![self isVertical]) return;
	
	
	
	
	// no we build out tranform for the arrow itself,  this depends on the configuration and which arrow we trying to draw
	NSAffineTransform *arrowTransform = [NSAffineTransform transform];
	if (whichArrow == NSScrollerDecrementArrow) {
		[arrowTransform rotateByDegrees:180.0];
		if ([self arrowsSetting] == ESScrollerArrowsDoubleMax)
			[arrowTransform translateXBy:-frame.size.width yBy:-2*([self frame].size.height - 15) + frame.size.height + 1];
		else
			[arrowTransform translateXBy:-frame.size.width yBy:-frame.size.height];
	}
	
	[self drawArrowInRect:frame withTransform:arrowTransform];
	
	// as the arrow transform but for the socket
	NSAffineTransform *socketTransform = [NSAffineTransform transform];
	if (whichArrow == NSScrollerIncrementArrow) {
		[socketTransform rotateByDegrees:180.0];
		if ([self arrowsSetting] == ESScrollerArrowsSingle)
			[socketTransform translateXBy:-frame.size.width yBy:-2*([self frame].size.height) + frame.size.height + 0.5];
	}
	
	if (whichArrow == NSScrollerDecrementArrow && [self arrowsSetting] == ESScrollerArrowsDoubleMax) {
		[socketTransform rotateByDegrees:180.0];
		[socketTransform translateXBy:-frame.size.width yBy:-2*([self frame].size.height) + 3*frame.size.height + 5];
	}
	
	[self drawCurvedSocketForArrow:whichArrow inRect:frame transform:socketTransform highlight:highlight];
	
	[self drawArrowBackgroundEdgeForRect:frame highlight:highlight];
}

// fill knob first, then stroke it
- (void)drawKnob;
{
	NSRect knobFrame = [self rectForPart:NSScrollerKnob];
	NSBezierPath *knobOutline = [NSBezierPath bezierPathWithRoundedRect:knobFrame xRadius:ESScrollerCornerXRadius yRadius:ESScrollerCornerYRadius];
	[[NSColor colorWithCalibratedWhite:0.4 alpha:1.0] setStroke];
	[knobOutline setLineWidth:ESScrollerKnobStrokeWidth];
	NSBezierPath *knobFill = [NSBezierPath bezierPathWithRoundedRect:knobFrame xRadius:ESScrollerCornerXRadius yRadius:ESScrollerCornerYRadius];
	
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	if ([[activeApp valueForKey:@"NSApplicationBundleIdentifier"] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
		[self.foregroundWindowKnobGradient drawInBezierPath:knobFill angle:[self fillAngle]];
	else
		[self.backgroundWindowKnobGradient drawInBezierPath:knobFill angle:[self fillAngle]];
	[knobOutline setLineCapStyle:NSButtLineCapStyle];
	[knobOutline stroke];
}

// this may need an alternative gradient when the app is background.
- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag;
{
	[self.knobSlotGradient drawInRect:slotRect angle:[self fillAngle]];
}
@end
