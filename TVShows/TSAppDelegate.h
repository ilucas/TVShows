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

@import Foundation;
@import CocoaLumberjack;

NS_ASSUME_NONNULL_BEGIN

//extern DDLogLevel const ddLogLevel;

extern NSString * const kApplicationName;
extern NSString * const kApplicationGroup;

@interface TSAppDelegate : NSObject

@property (nonatomic, readonly) NSString *applicationSupportDirectory;
@property (nonatomic, readonly) NSString *applicationCacheDirectory;
@property (nonatomic, readonly) NSURL *persistentStoreURL;
@property (nonatomic, readonly) NSURL *groupContainerURL;

- (void)setupLogging;
- (void)setupCoreData;

- (NSUserDefaults *)sharedUserDefaults;

@end

NS_ASSUME_NONNULL_END
