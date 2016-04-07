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

#import "LaunchAgent.h"

@import CocoaLumberjack;

const CFStringRef static kHelperIdentifier = CFSTR("com.TVShows.Helper");

@implementation LaunchAgent

+ (NSArray *)allJobs {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFArrayRef jobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
#pragma clang diagnostic pop
    
    return CFBridgingRelease(jobs);
}

+ (NSDictionary *)jobDictionary {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFDictionaryRef job = SMJobCopyDictionary(kSMDomainUserLaunchd, kHelperIdentifier);
#pragma clang diagnostic pop
    
    return CFBridgingRelease(job);
}

+ (BOOL)loginItemIsEnabled {
    return ([self jobDictionary] != nil);
}

+ (BOOL)enabledLoginItem:(BOOL)flag {
    BOOL status = SMLoginItemSetEnabled(kHelperIdentifier, flag);
    
    if (!status) {
        DDLogError(@"SMLoginItemSetEnabled(Flag: %@) Failed", (flag ? @"YES" : @"NO"));
    }
    
    return status;
}

@end
