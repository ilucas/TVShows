/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Cocoa/Cocoa.h>
#import "TVShows_Prefix.pch"
#import "AppInfoConstants.h"

// Thanks to Matt Patenaude and his blog post on how to relaunch an application.
// Slightly modified to work with a Preference Pane and a Launch Helper.
// http://iloveco.de/relaunching-your-application/

void relaunchHelper(NSString *launchAgentPath)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSTask *aTask = [[NSTask alloc] init];
    [aTask setLaunchPath:@"/bin/launchctl"];
    [aTask setArguments:[NSArray arrayWithObjects:@"load",@"-w",launchAgentPath,nil]];
    [aTask launch];
    [aTask waitUntilExit];
    [aTask release];
    
    [pool drain];
}

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    pid_t parentPID = atoi(argv[3]);
    ProcessSerialNumber psn;
    while (GetProcessForPID(parentPID, &psn) != procNotFound)
        sleep(1);
    
    NSString *appPath = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    NSString *prefPath = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
    BOOL success = NO;
    
    if (prefPath.length == 0) {
        relaunchHelper(appPath);
        success = YES;
    } else {
        success = [[NSWorkspace sharedWorkspace] openFile:[prefPath stringByExpandingTildeInPath]
                                          withApplication:[appPath stringByExpandingTildeInPath]];
    }
    
    if (!success)
        NSLog(@"Could not relaunch application at %@", appPath);
    
    [pool drain];
    return (success) ? 0 : 1;
}
