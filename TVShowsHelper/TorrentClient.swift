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

import Cocoa

@objc
class TorrentClient: NSObject {
    
    class func openTorrent(magnet: NSString) -> Bool {
        let magnetLink = NSURL.init(string: magnet as String)
        let workspace = NSWorkspace.sharedWorkspace()
        
        return workspace.openURLs([magnetLink!],
                                  withAppBundleIdentifier: nil,
                                  options: .WithoutActivation,// NSWorkspaceLaunchWithoutActivation will not show the torrent client.
                                  additionalEventParamDescriptor: nil,
                                  launchIdentifiers: nil)
    }
    
}
