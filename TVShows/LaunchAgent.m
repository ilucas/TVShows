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

static NSString * const kHelperIdentifier = @"com.TVShows.Helper";

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
    CFDictionaryRef job = SMJobCopyDictionary(kSMDomainUserLaunchd, CFBridgingRetain(kHelperIdentifier));
#pragma clang diagnostic pop

    return CFBridgingRelease(job);
}

#pragma mark - 

+ (NSString *)launchAgentPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] firstObject];
    libraryURL = [libraryURL URLByAppendingPathComponent:@"LaunchAgents" isDirectory:YES];
    libraryURL = [libraryURL URLByAppendingPathComponent:kHelperIdentifier isDirectory:NO];
    libraryURL = [libraryURL URLByAppendingPathExtension:@"plist"];
    
    return [libraryURL path];
}

+ (NSMutableDictionary *)launchAgentDisctionary {
    // Create an NSDictionary for saving into a LaunchAgent plist.
    NSMutableDictionary *launchAgent = [NSMutableDictionary dictionary];
    
    // Label: Uniquely identifies the job to launchd.
    [launchAgent setObject:kHelperIdentifier forKey:@"Label"];
    
    // Program: Tells launchd the location of the program to launch.
    NSString *program = [[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"TVShowsHelper.app"]
                         stringByAppendingPathComponent:@"Contents/MacOS/TVShowsHelper"];
    [launchAgent setObject:program forKey:@"Program"];
    
    // RunAtLoad: Controls whether your job is launched immediately after the job is loaded.
    [launchAgent setObject:@YES forKey:@"RunAtLoad"];
    
    // Disabled: Controls whether the job is disabled;
    //[launchAgent setObject:@YES forKey:@"Disabled"];
    
    // LowPriorityIO: Specifies whether the daemon is low priority when doing file system I/O.
    [launchAgent setObject:@YES forKey:@"LowPriorityIO"];
    
    // LaunchOnlyOnce: Avoid launching more than once.
    [launchAgent setObject:@YES forKey:@"LaunchOnlyOnce"];
    
    [launchAgent setObject:@YES forKey:@"KeepAlive"];
    
    return launchAgent;
}

+ (BOOL)loginItemIsEnabled {
    NSString *launchAgentPath = [self launchAgentPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:launchAgentPath]) {
        // get the file and check for the Disabled key.
        NSDictionary *launchAgent = [NSDictionary dictionaryWithContentsOfFile:launchAgentPath];
        NSNumber *disabled = launchAgent[@"Disabled"];
        
        return !disabled.boolValue;
    }
    
    // File dont't exists.
    return false;
}

+ (BOOL)enabledLoginItem:(BOOL)flag {
    NSString *launchAgentPath = [self launchAgentPath];
    NSMutableDictionary *launchAgent = [self launchAgentDisctionary];
    
    // Set the Disabled flag.
    [launchAgent setObject:[NSNumber numberWithBool:!flag] forKey:@"Disabled"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create the Launch Agent directory for the user (just in case)
    if (![fileManager fileExistsAtPath:[launchAgentPath stringByDeletingLastPathComponent]]) {
        NSError *error;
        [fileManager createDirectoryAtPath:[launchAgentPath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error) {
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
            return false;
        }
    }
    
    if (![launchAgent writeToFile:launchAgentPath atomically:YES]) {
        NSString *error = [@"Could not write to " stringByAppendingString:launchAgentPath];
        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
        return false;
    }
    
    if (flag) {
        [self loadLaunchAgent:launchAgentPath];
    } else {
        [self unloadLaunchAgent:launchAgentPath];
    }
    
    return true;
}

#pragma mark - Private 

// Unload the old LaunchAgent if it exists.
+ (void)unloadLaunchAgent:(NSString *)launchAgentPath {
    NSTask *aTask = [[NSTask alloc] init];
    [aTask setLaunchPath:@"/bin/launchctl"];
    [aTask setArguments:@[@"unload", @"-w", launchAgentPath]];
    [aTask launch];
}

// Loads the LaunchAgent.
+ (void)loadLaunchAgent:(NSString *)launchAgentPath {
    NSTask *aTask = [[NSTask alloc] init];
    [aTask setLaunchPath:@"/bin/launchctl"];
    [aTask setArguments:@[@"load", @"-w", launchAgentPath]];
    [aTask launch];
}

@end
