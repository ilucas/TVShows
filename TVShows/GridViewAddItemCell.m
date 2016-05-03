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

#import "GridViewAddItemCell.h"
#import "OECoverGridDataSourceItem.h"
#import "OEGridView.h"

@import libextobjc;

static const CGFloat OEGridCellTitleHeight = 16.0;// Height of the title view
static const CGFloat OEGridCellImageTitleSpacing = 17.0;// Space between the image and the title

static const CGFloat OEGridCellImageContainerLeft = 13.0;
static const CGFloat OEGridCellImageContainerTop = 7.0;
static const CGFloat OEGridCellImageContainerRight = 13.0;
static const CGFloat OEGridCellImageContainerBottom = OEGridCellTitleHeight + OEGridCellImageTitleSpacing;

static CGColorRef placeHolderStrokeColoRef;
static CGColorRef placeHolderFillColoRef;

static NSDictionary *disabledActions;

@interface GridViewAddItemCell ()

@property (nonatomic, strong) NSImage *selectorImage;

@property (nonatomic, strong) CALayer *foregroundLayer;
@property (nonatomic, strong) CALayer *backgroundLayer;
@property (nonatomic, strong) CATextLayer *textLayer;

@property (assign) BOOL lastWindowActive;
@property (assign) NSSize lastImageSize;

@end

@implementation GridViewAddItemCell

#pragma mark - Drawing

#pragma mark - Frames

- (NSImageAlignment)imageAlignment {
    return NSImageAlignBottom;
}

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
    frame.origin.y = [self frame].origin.y;
    
    return frame;
}

- (NSRect)selectionFrame{
    return [self imageFrame];
}

- (NSRect)OE_relativeFrameFromFrame:(NSRect)rect
{
    NSRect frame = [self frame];
    frame = NSMakeRect(rect.origin.x - frame.origin.x, rect.origin.y - frame.origin.y, rect.size.width, rect.size.height);
    
    return NSIntegralRectWithOptions(frame, NSAlignAllEdgesOutward);
}

- (NSRect)relativeImageFrame
{
    return [self OE_relativeFrameFromFrame:[self imageFrame]];
}

- (NSRect)relativeTitleFrame
{
    return [self OE_relativeFrameFromFrame:[self titleFrame]];
}

- (NSRect)relativeSubtitleFrame
{
    return [self OE_relativeFrameFromFrame:[self subtitleFrame]];
}

#pragma mark - Layers & Images

- (void)setupLayers {
    self.foregroundLayer = [CALayer layer];
    [self.foregroundLayer setActions:disabledActions];
    
    // setup title layer
    CTFontRef titleFont = CFBridgingRetain([NSFont boldSystemFontOfSize:12]);
    
    @onExit {
        CFRelease(titleFont);
    };
    
    self.textLayer = [CATextLayer layer];
    [self.textLayer setActions:disabledActions];
    
    [self.textLayer setAlignmentMode:kCAAlignmentCenter];
    [self.textLayer setTruncationMode:kCATruncationEnd];
    [self.textLayer setForegroundColor:[[NSColor whiteColor] CGColor]];
    [self.textLayer setFont:titleFont];
    [self.textLayer setFontSize:12.0];
    
    [self.textLayer setShadowColor:[[NSColor blackColor] CGColor]];
    [self.textLayer setShadowOffset:CGSizeMake(0.0, -1.0)];
    [self.textLayer setShadowRadius:1.0];
    [self.textLayer setShadowOpacity:1.0];
    [self.foregroundLayer addSublayer:self.textLayer];
    
    // setup background layer
    self.backgroundLayer = [CALayer layer];
    [self.backgroundLayer setActions:disabledActions];
    [self.backgroundLayer setShadowColor:[[NSColor blackColor] CGColor]];
    [self.backgroundLayer setShadowOffset:CGSizeMake(0.0, -1.0)];
    [self.backgroundLayer setShadowRadius:1.0];
    [self.backgroundLayer setContentsGravity:kCAGravityResize];
}

- (CALayer *)layerForType:(NSString *)type {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    const OEGridView *browser = [self imageBrowserView];
    const NSWindow   *window  = [browser window];
    const CGFloat scaleFactor = [[window screen] backingScaleFactor];
    const id<OECoverGridDataSourceItem> representedItem = [self representedItem];
    
    // absolute rects
    const NSRect frame  = [self frame];
    const NSRect bounds = {{0,0}, frame.size};
    
    // relative rects
    const NSRect relativeImageFrame  = [self relativeImageFrame];
    const NSRect relativeTitleFrame  = [self relativeTitleFrame];
    
    // Create a placeholder layer
    if(type == IKImageBrowserCellPlaceHolderLayer){
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
        [CATransaction commit];
        return _backgroundLayer;
    }
    
    DDLogInfo(@"Unkown layer type: %@", type);
    [CATransaction commit];
    
    return [super layerForType:type];
}

#pragma mark - Apple Private Overrides

- (BOOL)acceptsDrop {
    return false;
}

- (void)drawDragHighlight{}
- (void)drawSelection{}
- (void)drawSubtitle{}
- (void)drawTitleBackground{}
- (void)drawSelectionOnTitle{}
- (void)drawImageOutline{}
- (void)drawShadow{}

#pragma mark - LifeCycle

+ (void)initialize{
    const CGFloat fillComponents[4] = {1.0, 1.0, 1.0, 0.08};
    const CGFloat strokeComponents[4] = {1.0, 1.0, 1.0, 0.1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    placeHolderStrokeColoRef = CGColorCreate(colorSpace, strokeComponents);
    placeHolderFillColoRef   = CGColorCreate(colorSpace, fillComponents);
    
    CGColorSpaceRelease(colorSpace);
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        if (disabledActions == nil) {
            disabledActions = @{@"position": [NSNull null],
                                @"bounds": [NSNull null],
                                @"frame": [NSNull null],
                                @"contents": [NSNull null]};
        }
        
        [self setupLayers];
    }
    
    return self;
}

@end
