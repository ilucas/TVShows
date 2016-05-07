/*
 *  This file is part of the TVShows source code.
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

#import "GridViewSubscriptionItemCell.h"
#import "GridViewCellIndicationLayer.h"

#import "IKImageBrowserCell.h"

#import "OEGameGridViewDelegate.h"
#import "OECoverGridDataSourceItem.h"

static const CGFloat OEGridCellTitleHeight          = 16.0; // Height of the title view
static const CGFloat OEGridCellImageTitleSpacing    = 17.0; // Space between the image and the title
static const CGFloat OEGridCellSubtitleHeight       = 11.0; // Subtitle height
static const CGFloat OEGridCellSubtitleWidth        = 56.0; // Subtitle width
static const CGFloat OEGridCellSubtitleTitleSpace   = 4.0;  // Space between title and subtitle
static const CGFloat OEGridCellImageContainerLeft   = 13.0;
static const CGFloat OEGridCellImageContainerTop    = 7.0;
static const CGFloat OEGridCellImageContainerRight  = 13.0;
static const CGFloat OEGridCellImageContainerBottom = OEGridCellTitleHeight + OEGridCellImageTitleSpacing + OEGridCellSubtitleHeight + OEGridCellSubtitleTitleSpace;

static CGColorRef placeHolderStrokeColoRef;
static CGColorRef placeHolderFillColoRef;

static NSDictionary *disabledActions;

@interface GridViewSubscriptionItemCell ()

@property NSImage *selectorImage;

@property CALayer *selectionLayer;
@property CALayer *foregroundLayer;
@property CATextLayer *textLayer;
@property CALayer *ratingLayer;
@property CALayer *backgroundLayer;
@property CALayer *missingArtworkLayer;
@property CALayer *proposedImageLayer;
@property NSSize lastImageSize;

@property GridViewCellIndicationLayer *indicationLayer;

@property BOOL lastWindowActive;

@end

@implementation GridViewSubscriptionItemCell

#pragma mark - Frames

- (NSRect)imageContainerFrame {
    NSRect frame = [super imageContainerFrame];
    frame.origin.x += OEGridCellImageContainerLeft;
    frame.origin.y = [self frame].origin.y + OEGridCellImageContainerBottom;
    frame.size.width -= OEGridCellImageContainerLeft + OEGridCellImageContainerRight;
    frame.size.height -= OEGridCellImageContainerTop + OEGridCellImageContainerBottom;
    
    return frame;
}

- (NSRect)titleFrame {
    NSRect frame;
    
    frame.size.width = [self frame].size.width;
    frame.size.height = OEGridCellTitleHeight;
    frame.origin.x = [self frame].origin.x;
    frame.origin.y = [self frame].origin.y + OEGridCellSubtitleHeight + OEGridCellSubtitleTitleSpace;
    
    return frame;
}

- (NSRect)ratingFrame {
    NSRect frame;
    
    frame.size.width  = OEGridCellSubtitleWidth;
    frame.size.height = OEGridCellSubtitleHeight;
    frame.origin.x = NSMidX([self frame]) - OEGridCellSubtitleWidth / 2.0;
    frame.origin.y = [self frame].origin.y;
    
    return frame;
}

- (NSRect)selectionFrame {
    return [self imageFrame];
}

- (NSRect)deleteButtonFrame {
    return NSMakeRect(0, 0, 25, 25);
}

- (NSRect)relativeFrameFromFrame:(NSRect)rect {
    NSRect frame = [self frame];
    frame = NSMakeRect(rect.origin.x - frame.origin.x, rect.origin.y - frame.origin.y, rect.size.width, rect.size.height);
    
    return NSIntegralRectWithOptions(frame, NSAlignAllEdgesOutward);
}

- (NSRect)relativeImageFrame {
    return [self relativeFrameFromFrame:[self imageFrame]];
}

- (NSRect)relativeTitleFrame {
    return [self relativeFrameFromFrame:[self titleFrame]];
}

- (NSRect)relativeRatingFrame {
    return [self relativeFrameFromFrame:[self ratingFrame]];
}

- (NSPoint)convertPointFromViewToForegroundLayer:(NSPoint)p {
    NSRect frame = [self frame];
    
    return NSMakePoint(p.x - frame.origin.x, p.y - frame.origin.y);
}

#pragma mark - Layers & Images

- (void)setupLayers {
    _foregroundLayer = [CALayer layer];
    [_foregroundLayer setActions:disabledActions];
    
    // setup title layer
    const CGFloat titleFontSize = [NSFont systemFontSize];
    NSFont *titleFont = [NSFont systemFontOfSize:titleFontSize weight:NSFontWeightMedium];
    
    _textLayer = [CATextLayer layer];
    [_textLayer setActions:disabledActions];
    
    [_textLayer setAlignmentMode:kCAAlignmentCenter];
    [_textLayer setTruncationMode:kCATruncationEnd];
    [_textLayer setForegroundColor:[[NSColor whiteColor] CGColor]];
    [_textLayer setFont:(__bridge CTFontRef)titleFont];
    [_textLayer setFontSize:titleFontSize];
    
    [_foregroundLayer addSublayer:_textLayer];
    
    // setup rating layer
    _ratingLayer = [CALayer layer];
    [_ratingLayer setActions:disabledActions];
    [_foregroundLayer addSublayer:_ratingLayer];
    
    _missingArtworkLayer = [CALayer layer];
    [_missingArtworkLayer setActions:disabledActions];
    [_foregroundLayer addSublayer:_missingArtworkLayer];
    
    _indicationLayer = [[GridViewCellIndicationLayer alloc] init];
    [_indicationLayer setType:GridViewCellIndicationTypeNone];
    [_foregroundLayer addSublayer:_indicationLayer];
    
    // setup background layer
    _backgroundLayer = [CALayer layer];
    [_backgroundLayer setActions:disabledActions];
    [_backgroundLayer setShadowColor:[[NSColor blackColor] CGColor]];
    [_backgroundLayer setShadowOffset:CGSizeMake(0.0, -1.0)];
    [_backgroundLayer setShadowRadius:1.0];
    [_backgroundLayer setContentsGravity:kCAGravityResize];
}

- (CALayer *)layerForType:(NSString *)type {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    const OEGridView *browser = [self imageBrowserView];
    const NSWindow   *window  = [browser window];
    const CGFloat scaleFactor = [[window screen] backingScaleFactor];
    const BOOL   windowActive = [window isKeyWindow] && [window firstResponder]==browser;
    const BOOL   isSelected   = [self isSelected];
    const IKImageBrowserCellState state = [self cellState];
    const id<OECoverGridDataSourceItem> representedItem = [self representedItem];
    const NSString *identifier = [representedItem imageUID];
    
    // absolute rects
    const NSRect frame  = [self frame];
    const NSRect bounds = {{0,0}, frame.size};
    
    // relative rects
    const NSRect relativeImageFrame  = [self relativeImageFrame];
    const NSRect relativeTitleFrame  = [self relativeTitleFrame];
    const NSRect relativeRatingFrame = [self relativeRatingFrame];
    
    // Create a placeholder layer
    if (type == IKImageBrowserCellPlaceHolderLayer) {
        CALayer *layer = [CALayer layer];
        [layer setActions:disabledActions];
        
        [layer setFrame:bounds];
        
        CALayer *placeHolderLayer = [CALayer layer];
        [placeHolderLayer setFrame:relativeImageFrame];
        [placeHolderLayer setActions:disabledActions];
        
        //set a background color
        [placeHolderLayer setBackgroundColor:placeHolderFillColoRef];
        
        //set a stroke color
        [placeHolderLayer setBorderColor:placeHolderStrokeColoRef];
        
        [placeHolderLayer setBorderWidth:1.0];
        [placeHolderLayer setCornerRadius:10];
        
        [layer addSublayer:placeHolderLayer];
        
        [CATransaction commit];
        return layer;
    }
    
    // foreground layer
    if (type == IKImageBrowserCellForegroundLayer) {
        [_foregroundLayer setFrame:bounds];
        
        NSString *imageTitle = [representedItem imageTitle];
        [_textLayer setContentsScale:scaleFactor];
        [_textLayer setFrame:relativeTitleFrame];
        [_textLayer setString:imageTitle];
        
        // Setup rating layer
        NSUInteger    rating = [representedItem gridRating];
        NSImage *ratingImage = [self ratingImageForRating:rating];
        
        [_ratingLayer setContentsGravity:kCAGravityResizeAspect];
        [_ratingLayer setContentsScale:scaleFactor];
        [_ratingLayer setFrame:relativeRatingFrame];
        [_ratingLayer setContents:ratingImage];
        
        if (state == IKImageStateReady) {
            if ([identifier characterAtIndex:0] == ':' && !NSEqualSizes(relativeImageFrame.size, _lastImageSize)) {
                NSImage *missingArtworkImage = [self missingArtworkImageWithSize:relativeImageFrame.size];
                [_missingArtworkLayer setFrame:relativeImageFrame];
                [_missingArtworkLayer setContents:missingArtworkImage];
                _lastImageSize = relativeImageFrame.size;
            }
            
            if ([identifier characterAtIndex:0]!=':') {
                [_missingArtworkLayer setContents:nil];
            }
            
            [self updateIndicationLayer];
            
            [_indicationLayer setFrame:relativeImageFrame];
        } else {
            [_proposedImageLayer removeFromSuperlayer];
            [_indicationLayer setType:GridViewCellIndicationTypeNone];
        }
        
        // the selection layer is cached else the CATransition initialization fires the layers to be redrawn which causes the CATransition to be initalized again: loop
        if (!CGRectEqualToRect([_selectionLayer frame], CGRectInset(relativeImageFrame, -6.0, -6.0)) || windowActive != _lastWindowActive) {
            [_selectionLayer removeFromSuperlayer];
            _selectionLayer = nil;
        }
        
        if (isSelected && (!_selectionLayer || windowActive != _lastWindowActive)) {
            _lastWindowActive = windowActive;
            
            CGRect selectionFrame = CGRectInset(relativeImageFrame, -6.0, -6.0);
            CALayer *selectionLayer = [CALayer layer];
            selectionLayer.actions = disabledActions;
            selectionLayer.frame = selectionFrame;
            
            selectionLayer.borderWidth = 4.0;
            selectionLayer.borderColor = _lastWindowActive ?
            [NSColor colorWithCalibratedRed:0.243
                                      green:0.502
                                       blue:0.871
                                      alpha:1.0].CGColor :
            [NSColor colorWithCalibratedWhite:0.651
                                        alpha:1.0].CGColor;
            selectionLayer.cornerRadius = 3.0;
            
            [_foregroundLayer addSublayer:selectionLayer];
            
            _selectionLayer = selectionLayer;
        } else if(!isSelected) {
            [_selectionLayer removeFromSuperlayer];
            _selectionLayer = nil;
        }
        
        [CATransaction commit];
        return _foregroundLayer;
    }
    
    // create a selection layer to prevent defaults
    if (type == IKImageBrowserCellSelectionLayer) {
        CALayer *layer = [CALayer layer];
        [layer setActions:disabledActions];
        [CATransaction commit];
        return layer;
    }
    
    // background layer
    if (type == IKImageBrowserCellBackgroundLayer) {
        [_backgroundLayer setFrame:bounds];
        
        // add shadow if image is loaded
        if(state == IKImageStateReady) {
            CGPathRef shadowPath = CGPathCreateWithRect(relativeImageFrame, NULL);
            [_backgroundLayer setShadowPath:shadowPath];
            CGPathRelease(shadowPath);
            [_backgroundLayer setShadowOpacity:1.0];
        } else {
            [_backgroundLayer setShadowOpacity:0.0];
        }
        
        [CATransaction commit];
        return _backgroundLayer;
    }
    
    DDLogInfo(@"%s [Line %d]: Unkown layer type: %@",__PRETTY_FUNCTION__, __LINE__, type);
    [CATransaction commit];
    return [super layerForType:type];
}

- (NSImage *)missingArtworkImageWithSize:(NSSize)size {
    return [[self class] missingArtworkImageWithSize:size];
}

+ (NSImage *)missingArtworkImageWithSize:(NSSize)size {
    if(NSEqualSizes(size, NSZeroSize)) return nil;
    
    static NSCache *cache = nil;
    if(cache == nil) {
        cache = [[NSCache alloc] init];
        [cache setCountLimit:25];
    }
    
    NSString *key = NSStringFromSize(size);
    NSImage *missingArtwork = [cache objectForKey:key];
    if (missingArtwork) return missingArtwork;
    
    missingArtwork = [[NSImage alloc] initWithSize:size];
    [missingArtwork lockFocus];
    
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [currentContext saveGraphicsState];
    [currentContext setShouldAntialias:NO];
    
    NSImage      *scanLineImage     = [NSImage imageNamed:@"missing_artwork"];
    const NSSize  scanLineImageSize = [scanLineImage size];
    
    CGRect scanLineRect = CGRectMake(0.0, 0.0, size.width, scanLineImageSize.height);
    
    for (CGFloat y = 0.0; y < size.height; y += scanLineImageSize.height) {
        scanLineRect.origin.y = y;
        [scanLineImage drawInRect:scanLineRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    }
    
    [currentContext restoreGraphicsState];
    [missingArtwork unlockFocus];
    
    // Cache the image for later use
    [cache setObject:missingArtwork forKey:key cost:size.width*size.height];
    
    return missingArtwork;
}

- (NSImage *)ratingImageForRating:(NSInteger)rating {
    const int MaxRating = 6;
    NSAssert(rating >= 0 && rating < MaxRating, @"Rating out of bounds!");
    static NSImage *ratings[MaxRating];
    
    if (ratings[rating] == nil) {
        ratings[rating] = [self  newRatingImageForRating:rating];
    }
    
     return ratings[rating];
}

- (NSImage *)newRatingImageForRating:(NSInteger)rating {
    const NSUInteger OECoverGridViewCellRatingViewNumberOfRatings = 6;
    const NSImage *ratingImage    = [NSImage imageNamed:@"grid_rating"];
    const NSSize  ratingImageSize = [ratingImage size];
    const CGFloat ratingStarHeight      = ratingImageSize.height / OECoverGridViewCellRatingViewNumberOfRatings;
    const NSRect  ratingImageSourceRect = NSMakeRect(0.0, ratingImageSize.height - ratingStarHeight * (rating + 1.0), ratingImageSize.width, ratingStarHeight);
    
    return [ratingImage subImageFromRect:ratingImageSourceRect];
}

- (GridViewCellIndicationType)recalculateType {
    return (GridViewCellIndicationType)[(id <OECoverGridDataSourceItem>)[self representedItem] gridStatus];
}

- (void)updateIndicationLayer {
    GridViewCellIndicationType newType = [self recalculateType];
    
    [_indicationLayer setType:newType];
}

#pragma mark - Interaction

- (BOOL)mouseEntered:(NSEvent *)theEvent {
    NSPoint locationInWindow = [theEvent locationInWindow];
    NSPoint location = [[self imageBrowserView] convertPoint:locationInWindow fromView:nil];
    location = [self convertPointFromViewToForegroundLayer:location];
    
    [[self imageBrowserView] reloadCellDataAtIndex:[self indexOfRepresentedItem]];
    
    return YES;
}

- (BOOL)mouseMoved:(NSEvent *)theEvent {
    return [self mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[self imageBrowserView] reloadCellDataAtIndex:[self indexOfRepresentedItem]];
}

- (BOOL)mouseDown:(NSEvent *)theEvent {
    NSPoint locationInWindow = [theEvent locationInWindow];
    NSPoint location = [[self imageBrowserView] convertPoint:locationInWindow fromView:nil];
    location = [self convertPointFromViewToForegroundLayer:location];
    
    [[self imageBrowserView] reloadCellDataAtIndex:[self indexOfRepresentedItem]];
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint locationInWindow = [theEvent locationInWindow];
    NSPoint location = [[self imageBrowserView] convertPoint:locationInWindow fromView:nil];
    location = [self convertPointFromViewToForegroundLayer:location];
    
    [[self imageBrowserView] reloadCellDataAtIndex:[self indexOfRepresentedItem]];
}

#pragma mark - Apple Private Overrides

- (BOOL)acceptsDrop {
    return [[self imageBrowserView] proposedImage] != nil;
}

- (void)drawDragHighlight{}
- (void)drawSelection{}
- (void)drawSubtitle{}
- (void)drawTitleBackground{}
- (void)drawSelectionOnTitle{}
- (void)drawImageOutline{}
- (void)drawShadow{}

#pragma mark - Init

+ (void)initialize {
    const CGFloat fillComponents[4]   = {1.0, 1.0, 1.0, 0.08};
    const CGFloat strokeComponents[4] = {1.0, 1.0, 1.0, 0.1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    placeHolderStrokeColoRef = CGColorCreate(colorSpace, strokeComponents);
    placeHolderFillColoRef   = CGColorCreate(colorSpace, fillComponents);
    
    CGColorSpaceRelease(colorSpace);
}

- (id)init {
    self = [super init];
    
    if (self) {
        if (disabledActions == nil)
            disabledActions = @{ @"position" : [NSNull null],
                                 @"bounds" : [NSNull null],
                                 @"frame" : [NSNull null],
                                 @"contents" : [NSNull null]};
        [self setupLayers];
    }
    
    return self;
}

@end
