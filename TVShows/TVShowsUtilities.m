//
//  TVShowsUtilities.m
//  TVShows
//
//  Created by Lucas on 23/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "TVShowsUtilities.h"

NSString * const kApplicationName = @"TVShows";
NSString * const kApplicationGroup = @"group.TVShows";

NSString *applicationSupportDirectory() {
    //NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *applicationStorageDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    
    return [applicationStorageDirectory stringByAppendingPathComponent:kApplicationName];
}

NSString *applicationCacheDirectory() {
    return [applicationSupportDirectory() stringByAppendingPathComponent:@"Cache"];
}

NSURL *persistentStoreURL() {
    NSURL *appSupportURL = [[NSURL alloc] initFileURLWithPath:applicationSupportDirectory() isDirectory:YES];
    NSString *storeName = [kApplicationName stringByAppendingPathExtension:@"sqlite"];
    
    return [appSupportURL URLByAppendingPathComponent:storeName];
}

NSURL *groupContainerURL() {
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kApplicationGroup];
}
