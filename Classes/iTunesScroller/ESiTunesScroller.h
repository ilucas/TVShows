//
//  ESiTunesScroller.h
//  ScrollBar
//
//  Created by Jonathan on 06/06/2008.
//  Copyright 2008 EspressoSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ESiTunesScroller : NSScroller {
@private
	NSGradient *_knobSlotGradient;
	NSGradient *_activeKnobGradient;
	NSGradient *_inactiveKnobGradient;
	NSGradient *_activeButtonGradient;
	NSGradient *_highlightButtonGradient;
	NSGradient *_inactiveButtonGradient;
	NSGradient *_activeArrowGradient;
	NSGradient *_inactiveArrowGradient;
	NSColor *_activeKnobOutlineColor;
	NSColor *_inactiveKnobOutlineColor;
	NSColor *_activeLineColor;
	NSColor *_highlightLineColor;
	NSColor *_inactiveLineColor;
}

@end
