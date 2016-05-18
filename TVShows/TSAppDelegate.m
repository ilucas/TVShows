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

#import "TSAppDelegate.h"
#import "CrashlyticsLogger.h"

@import Crashlytics;
@import MagicalRecord;
@import AFNetworkActivityLogger;

//DDLogLevel const ddLogLevel = DDLogLevelVerbose;

NSString * const kApplicationName = @"TVShows";
NSString * const kApplicationGroup = @"group.TVShows";

@interface TSAppDelegate ()
@property (nonatomic, readwrite) NSString *applicationSupportDirectory;
@property (nonatomic, readwrite) NSString *applicationCacheDirectory;
@property (nonatomic, readwrite) NSURL *persistentStoreURL;
@property (nonatomic, readwrite) NSURL *groupContainerURL;
@end

@implementation TSAppDelegate

#pragma mark - Setup

- (void)setupLogging {
    // Setup logging into XCode's console
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Setup Crashlytics log
    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];
    
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
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:self.persistentStoreURL];
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

#pragma mark - Properties

- (NSString *)applicationSupportDirectory {
    if (!_applicationSupportDirectory) {
        //NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
        //NSString *applicationStorageDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSURL *applicationStorageURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        _applicationSupportDirectory = [[applicationStorageURL URLByAppendingPathComponent:kApplicationName] path];
    }
    
    return _applicationSupportDirectory;
}

- (NSString *)applicationCacheDirectory {
    if (!_applicationCacheDirectory) {
        _applicationCacheDirectory = [self.applicationSupportDirectory stringByAppendingPathComponent:@"Cache"];
    }
    
    return _applicationCacheDirectory;
}

- (NSURL *)persistentStoreURL {
    if (!_persistentStoreURL) {
        NSURL *appSupportURL = [[NSURL alloc] initFileURLWithPath:self.applicationSupportDirectory isDirectory:YES];
        NSString *storeName = [kApplicationName stringByAppendingPathExtension:@"sqlite"];
        
        _persistentStoreURL = [appSupportURL URLByAppendingPathComponent:storeName];
    }
    
    return _persistentStoreURL;
}

- (NSURL *)groupContainerURL {
    if (!_groupContainerURL) {
        _groupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kApplicationGroup];
    }
    
    return _groupContainerURL;
}

@end
