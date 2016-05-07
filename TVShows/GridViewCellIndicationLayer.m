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

#import "GridViewCellIndicationLayer.h"
#import "NSColor+OEAdditions.h"

#define M_TAU (M_PI * 2.0)

static CGColorRef dropOnBackgroundColorRef;
static CGColorRef indicationShadowColorRef;
static CGColorRef missingFileBackgroundColorRef;
static CGColorRef processingItemBackgroundColorRef;

@interface GridViewCellIndicationLayer ()
+ (CAKeyframeAnimation *)rotationAnimation;
@end

@implementation GridViewCellIndicationLayer

#pragma mark - Overwrite

+ (void)initialize {
    dropOnBackgroundColorRef = CGColorCreateGenericRGB(0.4, 0.361, 0.871, 0.7);
    indicationShadowColorRef = CGColorCreateGenericRGB(0.341, 0.0, 0.012, 0.6);
    missingFileBackgroundColorRef = CGColorCreateGenericRGB(0.992, 0.0, 0.0, 0.4);
    processingItemBackgroundColorRef = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.7);
}

- (void)layoutSublayers {
    CALayer *sublayer = [[self sublayers] lastObject];
    if (!sublayer) return;
    
    const CGRect bounds = self.bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (self.type == GridViewCellIndicationTypeNone) {
        NSImage *overlayImage = [NSImage imageNamed:@"gloss_overlay"];
        
        const CGSize overlaySize = overlayImage.size;
        
        CGRect rect = bounds;
        rect.size = overlaySize;
        
        [sublayer setFrame:bounds];
    } else if (self.type == GridViewCellIndicationTypeEnded) {
        CGFloat width = CGRectGetWidth(bounds) / 2;
        CGFloat height = CGRectGetHeight(bounds);
        CGSize size = CGSizeMake(width, width);
        CGPoint origin = CGPointMake(0, height);
        
        CGRect frame = (CGRect){origin, size};
        
        [sublayer setFrame:frame];
    } else if (self.type == GridViewCellIndicationTypeDisabled) {
    
    } else if (self.type == GridViewCellIndicationTypeProcessing) {
    
    } else if (self.type == GridViewCellIndicationTypeFileMissing) {
    
    } else {
        DDLogError(@"%s [Line %d]: Invalid GridViewCellIndicationType", __PRETTY_FUNCTION__, __LINE__);
        [sublayer setFrame:bounds];
    }
    
    [CATransaction commit];
}

#pragma mark - Properties

- (void)setType:(GridViewCellIndicationType)type {
    _type = type;
    
    CALayer *sublayer = [[self sublayers] lastObject];
    
    if (sublayer == nil) {
        sublayer = [CALayer layer];
        [sublayer setActions:@{@"position": [NSNull null]}];
        [sublayer setShadowOffset:CGSizeMake(0.0, -1.0)];
        [sublayer setShadowOpacity:1.0];
        [sublayer setShadowRadius:1.0];
        [sublayer setShadowColor:indicationShadowColorRef];
        
        [self addSublayer:sublayer];
    } else {
        [sublayer removeAllAnimations];
    }
    
    if (self.type == GridViewCellIndicationTypeNone) {
        [sublayer setContents:[NSImage imageNamed:@"gloss_overlay"]];
        [sublayer setAnchorPoint:CGPointMake(0.5, 0.5)];
        [sublayer setAnchorPointZ:0.0];
    } else if (self.type == GridViewCellIndicationTypeEnded) {
        //[sublayer setContents:[NSImage imageNamed:@"ended_ribbon"]];
    } else if (self.type == GridViewCellIndicationTypeDisabled) {
        
    } else if (self.type == GridViewCellIndicationTypeProcessing) {
        
    } else if (self.type == GridViewCellIndicationTypeFileMissing) {
        [self setBackgroundColor:missingFileBackgroundColorRef];
        [sublayer setContents:[NSImage imageNamed:@"posterArtPlaceholder"]];
    } else {
        DDLogError(@"%s [Line %d]: Invalid GridViewCellIndicationType", __PRETTY_FUNCTION__, __LINE__);
    }
    
    [self setNeedsLayout];
}

#pragma mark - Private

+ (CAKeyframeAnimation *)rotationAnimation {
    static CAKeyframeAnimation *animation = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUInteger stepCount = 12;
        NSMutableArray *spinnerValues = [[NSMutableArray alloc] initWithCapacity:stepCount];
        
        for (NSUInteger step = 0; step < stepCount; step++)
            [spinnerValues addObject:[NSNumber numberWithDouble:-1*M_TAU * step / 12.0]];
        
        animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        [animation setCalculationMode:kCAAnimationDiscrete];
        [animation setDuration:1.0];
        [animation setRepeatCount:CGFLOAT_MAX];
        [animation setRemovedOnCompletion:NO];
        [animation setValues:spinnerValues];
    });
    
    return animation;
}

@end
