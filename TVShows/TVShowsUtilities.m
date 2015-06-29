//
//  TVShowsUtilities.m
//  TVShows
//
//  Created by Lucas on 23/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "TVShowsUtilities.h"

NSString *applicationSupportDirectory() {
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *applicationStorageDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    return [applicationStorageDirectory stringByAppendingPathComponent:applicationName];
}

NSString *applicationCacheDirectory() {
    return [applicationSupportDirectory() stringByAppendingPathComponent:@"Cache"];
}
