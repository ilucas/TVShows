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

extern DDLogLevel ddLogLevel;
extern NSString *NSStringFromDDLogLevel(DDLogLevel logLevel);

@interface LogLevel : NSObject

+ (DDLogLevel)ddLogLevel;
+ (void)ddSetLogLevel:(DDLogLevel)logLevel;

@end