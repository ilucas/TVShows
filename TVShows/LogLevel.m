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

#import "LogLevel.h"

DDLogLevel ddLogLevel = DDLogLevelInfo;

NSString *NSStringFromDDLogLevel(DDLogLevel logLevel) {
    switch (logLevel) {
        case DDLogLevelOff:
            return @"DDLogLevelOff";
            break;
        case DDLogLevelError:
            return @"DDLogLevelError";
            break;
        case DDLogLevelWarning:
            return @"DDLogLevelWarning";
            break;
        case DDLogLevelInfo:
            return @"DDLogLevelInfo";
            break;
        case DDLogLevelDebug:
            return @"DDLogLevelDebug";
            break;
        case DDLogLevelVerbose:
            return @"DDLogLevelVerbose";
            break;
        case DDLogLevelAll:
            return @"DDLogLevelAll";
            break;
        default:
            return @"";
            break;
    }
}

@implementation LogLevel

+ (DDLogLevel)ddLogLevel {
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    ddLogLevel = logLevel;
}

@end
