/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "CRViewSubclass.h"
#import "NSColor+BWAdditions.h"

@implementation CRViewSubclass
@synthesize startingColor, endingColor, angle;
@synthesize bottomBorderColor, topBorderColor;

#pragma mark - Setup

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    //[self setStartingColor:[NSColor colorWithCalibratedWhite:0.882 alpha:1.000]];
    //[self setEndingColor:[NSColor colorWithCalibratedWhite:0.737 alpha:1.000]];
    
    [self setStartingColor:[NSColor colorWithCalibratedWhite:0.950 alpha:1.000]];
    [self setEndingColor:[NSColor colorWithCalibratedWhite:0.850 alpha:1.000]];
    [self setTopBorderColor:[NSColor colorWithCalibratedWhite:0.520 alpha:1.000]];
    [self setBottomBorderColor:[NSColor colorWithCalibratedWhite:0.520 alpha:1.000]];
    
    [self setAngle:270.0];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)rect {
    if (endingColor == nil || [startingColor isEqual:endingColor]) {
        // If the start and end color are the same, fill with just one color.
        [startingColor set];
        NSRectFill(rect);
    } else {
        // Fill the view with a top-down gradient, from startingColor to endingColor
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startingColor
                                                             endingColor:endingColor];
        
        [gradient drawInRect:self.bounds angle:angle];
    }
    
    if (topBorderColor) {
        // Create a top border, if the topBorder color is set.
        [topBorderColor bwDrawPixelThickLineAtPosition: 0
                                             withInset: 0
                                                inRect: self.bounds
                                                inView: self
                                            horizontal: YES
                                                  flip: YES];
    }
    
    if (bottomBorderColor) {
        // Create a bottom border, if the bottomBorder color is set.
        [bottomBorderColor bwDrawPixelThickLineAtPosition: 0
                                                withInset: 0
                                                   inRect: self.bounds
                                                   inView: self
                                               horizontal: YES
                                                     flip: NO];
    }
}

#pragma mark - Interface Builder

- (void)prepareForInterfaceBuilder {
    [self setup];
}

@end
