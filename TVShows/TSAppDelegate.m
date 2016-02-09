//
//  TSAppDelegate.m
//  TVShows
//
//  Created by Lucas Casteletti on 2/9/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

#import "TSAppDelegate.h"

@import AFNetworkActivityLogger;

@implementation TSAppDelegate

#pragma mark - Setup

- (void)setupLogging {
    // Setup logging into XCode's console
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup AFNetworking log
    AFNetworkActivityLogger *afLogger = [AFNetworkActivityLogger sharedLogger];
    [afLogger setLevel:AFLoggerLevelInfo];
    [afLogger startLogging];
    
    // Setup logging to rolling log files
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setRollingFrequency:60 * 60 * 24]; // Roll logs every day
    [fileLogger setMaximumFileSize:1024 * 1024 * 2]; // max 2 mb
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:7]; // Keep 7 days only
    [DDLog addLogger:fileLogger];
}

- (void)setupCoreData {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:persistentStoreURL()];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelAll];
    [MagicalRecord enableShorthandMethods];
}

#pragma mark - NSUserDefaults

- (NSUserDefaults *)sharedUserDefaults {
    static NSUserDefaults *shared = nil;
    
    if (!shared) {
        shared = [[NSUserDefaults alloc] initWithSuiteName:kApplicationGroup];
    }
    
    return shared;
}

@end
