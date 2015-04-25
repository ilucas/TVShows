//
//  TSAbstractAPI.m
//  TVShows
//
//  Created by Lucas on 25/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "TSAbstractAPI.h"

@implementation TSAbstractAPI

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setCanceled:NO];
    }
    return self;
}

- (void)cancel {
    [self setCanceled:YES];
}

@end
