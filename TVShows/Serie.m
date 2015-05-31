//
//  Serie.m
//  TVShows
//
//  Created by Lucas on 25/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

#import <MagicalRecord/MagicalRecord.h>

@implementation Serie

- (BOOL)isComplete {
    // Since the first batch of series don't have a description, let's use seriesDescription to validate if the Serie is complete.
    return (self.seriesDescription != nil);
}

@end
