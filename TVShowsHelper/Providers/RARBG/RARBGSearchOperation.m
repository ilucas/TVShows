//
//  RARBGSearchOperation.m
//  TVShows
//
//  Created by Lucas casteletti on 2/20/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

#import "RARBGSearchOperation.h"

@implementation RARBGSearchOperation
@synthesize search;

+ (NSDictionary *)parameters {
    return @{@"mode": @"search",
             @"category": @"tv",
             @"format": @"json_extended",
             @"ranked": @"0"};
}

@end
