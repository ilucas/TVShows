//
//  ESScroller.h
//  ScrollBar
//
//  Created by Jonathan on 13/04/2008.
//  Copyright 2008 EspressoSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ESScroller : NSScroller {
	@private
	NSGradient *_foregroundWindowArrowBackgroundGradient;
	NSGradient *_backgroundWindowArrowBackgroundGradient;
	NSGradient *_foregroundWindowKnobGradient;
	NSGradient *_backgroundWindowKnobGradient;
	NSGradient *_knobSlotGradient;
	NSGradient *_arrowGradient;
	NSGradient *_backgroundWindowArrowGradient;
	NSColor *_foregroundWindowBoundaryColor;
	NSColor *_backgroundWindowBoundaryColor;
}
@end
