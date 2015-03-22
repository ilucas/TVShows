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

#import "InfoViewSubclass.h"

@implementation InfoViewSubclass

@synthesize startingColor, endingColor, angle;

- (id) initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setStartingColor:[NSColor colorWithCalibratedWhite:0.929 alpha:1.000]];
        [self setAngle:270];
    }
    
    return self;
}

- (void) drawRect:(NSRect)rect
{
    if (endingColor == nil || [startingColor isEqual:endingColor]) {
        // If the start and end color are the same, fill with just one color.
        [startingColor set];
        NSRectFill(rect);
    } else {
        // Fill the view with a top-down gradient, from startingColor to endingColor
        NSGradient* aGradient = [[NSGradient alloc]
                                 initWithStartingColor:startingColor
                                 endingColor:endingColor];
        
        [aGradient drawInRect:[self bounds] angle:angle];
    }
}

@end
