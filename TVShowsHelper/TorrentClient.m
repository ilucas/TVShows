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

#import "TorrentClient.h"
#import "AppDelegate.h"

@implementation TorrentClient

+ (BOOL)openTorrent:(NSString *)magnet {
    NSUserDefaults *defaults = [[NSApp delegate] sharedUserDefaults];
    NSString *identifier = [defaults objectForKey:@"torrentClient"][@"identifier"] ?: nil;
    
    return [[NSWorkspace sharedWorkspace] openURLs:@[[NSURL URLWithString:magnet]]
                           withAppBundleIdentifier:identifier
                                           options:NSWorkspaceLaunchWithoutActivation
                    additionalEventParamDescriptor:nil
                                 launchIdentifiers:nil];
}

@end
