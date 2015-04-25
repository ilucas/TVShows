//
//  TVShowsUtilities.m
//  TVShows
//
//  Created by Lucas on 23/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "TVShowsUtilities.h"

NSString *applicationCacheDirectory() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    return cacheDir;
}
