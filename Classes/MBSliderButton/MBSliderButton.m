/*
 Created on 28/02/2009
 Copyright 2009 Max Howell <max@methylblue.com>
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define KNOB_WIDTH 38
#define HEIGHT 26
#define WIDTH 89
#define KNOB_MIN_X 0
#define KNOB_MAX_X (WIDTH-KNOB_WIDTH)

@interface MBKnobAnimation : NSAnimation
{
    int start, range;
    id delegate;
}
@end
@implementation MBKnobAnimation
-(id)initWithStart:(int)begin end:(int)end
{
    [super init];
    start = begin;
    range = end - begin;
    return self;
}
-(void)setCurrentProgress:(NSAnimationProgress)progress
{
    int x = start+progress*range;
    [super setCurrentProgress:progress];
    [delegate performSelector:@selector(setPosition:) withObject:[NSNumber numberWithInteger:x]];
}
-(void)setDelegate:(id)d
{
    delegate = d;
}
@end


#import "MBSliderButton.h"
#import "PreferencesController.h"

@implementation MBSliderButton

-(void)awakeFromNib
{
    surround = [[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Toggle-Slider" ofType:@"png"]];
    knob = [[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Toggle-Knob" ofType:@"png"]];
    
    state = false;
}

-(void)drawRect:(NSRect)rect
{      
    NSColor* darkGreen = [NSColor colorWithDeviceRed:0.431 green:0.639 blue:0.118 alpha:1.0];
    NSColor* lightGreen = [NSColor colorWithDeviceRed:0.647 green:0.835 blue:0.247 alpha:1.0];    
    NSColor* darkGray = [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    NSColor* lightGray = [NSColor colorWithDeviceRed:0.7 green:0.7 blue:0.7 alpha:1.0];    
    
    NSGradient* green_gradient = [[NSGradient alloc] initWithStartingColor:darkGreen endingColor:lightGreen];
    NSGradient* gray_gradient = [[NSGradient alloc] initWithStartingColor:darkGray endingColor:lightGray];
    
    [green_gradient drawInRect:NSMakeRect(0, location.y, location.x+10, HEIGHT) angle:270];   
   
    NSString* s = TSLocalizeString(@"On");
    NSMutableDictionary* attr = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [NSFont boldSystemFontOfSize:15.0], NSFontAttributeName, 
                          [NSColor colorWithDeviceRed:0.2 green:0.333 blue:0.027 alpha:1.0], NSForegroundColorAttributeName, 
                          nil];
    
    NSSize sz = [s sizeWithAttributes:attr];
    NSPoint pt;
    pt.x = (KNOB_MAX_X-sz.width)/2 - (KNOB_MAX_X-location.x);
    pt.y = HEIGHT/2 - sz.height/2;
    [s drawAtPoint:pt withAttributes:attr];
    
    int x = location.x+KNOB_WIDTH-2;
    [gray_gradient drawInRect:NSMakeRect(x, location.y, WIDTH-x, HEIGHT) angle:270];
    
    s = TSLocalizeString(@"Off");
    [attr setObject:[NSColor colorWithDeviceWhite:0.2 alpha:0.66] forKey:NSForegroundColorAttributeName];
    sz = [s sizeWithAttributes:attr];
    pt.x = location.x+KNOB_WIDTH+(KNOB_MAX_X-sz.width)/2;
    [s drawAtPoint:pt withAttributes:attr];
    
    [surround drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect 
                                          operation:NSCompositeSourceOver
                                           fraction:1.0];
    pt = location;
    pt.x -= 2;
    [knob drawAtPoint:pt fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [green_gradient release];
    [gray_gradient release];
}

-(BOOL)isOpaque
{
    return YES;
}

-(NSInteger)state
{
    return state ? NSOnState : NSOffState;
}

-(void)animateTo:(int)x
{
    MBKnobAnimation* a = [[MBKnobAnimation alloc] initWithStart:location.x end:x];
    [a setDelegate:self];
    if (location.x == 0 || location.x == KNOB_MAX_X){
        [a setDuration:0.20];
        [a setAnimationCurve:NSAnimationEaseInOut];
    }else{
        [a setDuration:0.35 * ((fabs(location.x-x))/KNOB_MAX_X)];
        [a setAnimationCurve:NSAnimationLinear];
    }
    
    [a setAnimationBlockingMode:NSAnimationBlocking];
    [a startAnimation];
    [a release];
}

-(void)setPosition:(NSNumber*)x
{
    location.x = [x intValue];
    [self display];
}

-(void)setState:(NSInteger)newstate
{
    [self setState:newstate animate:true];
}

-(void)setState:(NSInteger)newstate animate:(bool)animate
{
    if(newstate == [self state])
        return;

    int x = newstate == NSOnState ? KNOB_MAX_X : 0;

    //TODO animate if  we are visible and otherwise don't
    if(animate)
        [self animateTo:x];
    else
        [self setNeedsDisplay:YES];

    state = newstate == NSOnState ? true : false;
    location.x = x;
}

-(void)offsetLocationByX:(float)x
{
    location.x = location.x + x;

    if (location.x < KNOB_MIN_X) location.x = KNOB_MIN_X;
    if (location.x > KNOB_MAX_X) location.x = KNOB_MAX_X;

    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)event
{
    BOOL loop = YES;

    // convert the initial click location into the view coords
    NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];

    // did the click occur in the draggable item?
    if (NSPointInRect(clickLocation, [self bounds])) {
        
        NSPoint newDragLocation;
        
        // the tight event loop pattern doesn't require the use
        // of any instance variables, so we'll use a local
        // variable localLastDragLocation instead.
        NSPoint localLastDragLocation;
        
        // save the starting location as the first relative point
        localLastDragLocation=clickLocation;
        
        while (loop) {
            // get the next event that is a mouse-up or mouse-dragged event
            NSEvent *localEvent;
            localEvent= [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            
            
            switch ([localEvent type]) {
                case NSLeftMouseDragged:
                    
                    // convert the new drag location into the view coords
                    newDragLocation = [self convertPoint:[localEvent locationInWindow]
                                                fromView:nil];
                    
                    
                    // offset the item and update the display
                    [self offsetLocationByX:(newDragLocation.x-localLastDragLocation.x)];
                    
                    // update the relative drag location;
                    localLastDragLocation = newDragLocation;
                    
                    // support automatic scrolling during a drag
                    // by calling NSView's autoscroll: method
                    [self autoscroll:localEvent];
                    
                    break;
                case NSLeftMouseUp:
                    // mouse up has been detected, 
                    // we can exit the loop
                    loop = NO;
                    
                    if (memcmp(&clickLocation, &localLastDragLocation, sizeof(NSPoint)) == 0)
                        [self animateTo:state ? 0 : KNOB_MAX_X];
                    else if (location.x > 0 && location.x < KNOB_MAX_X)
                        [self animateTo:state ? KNOB_MAX_X : 0];
                    
                    //TODO if let go of it halfway then slide to non destructive side
                    
                    if(location.x == 0 && state || location.x == KNOB_MAX_X && !state){
                        state = !state;
                        // wanted to use self.action and self.target but both are null
                        // even though I set them up in IB! :(
						id prefController = [PreferencesController alloc];
                        [prefController enabledControlDidChange:state];
						[prefController release];
                    }
                    
                    // the rectangle has moved, we need to reset our cursor
                    // rectangle
                    [[self window] invalidateCursorRectsForView:self];
                    
                    break;
                default:
                    // Ignore any other kind of event. 
                    break;
            }
        }
    };
    return;
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(IBAction)moveLeft:(id)sender
{
    [self offsetLocationByX:-10.0];
    [[self window] invalidateCursorRectsForView:self];
}

-(IBAction)moveRight:(id)sender
{
    [self offsetLocationByX:10.0];
    [[self window] invalidateCursorRectsForView:self];
}

@end
