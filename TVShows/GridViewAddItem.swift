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
import Quartz

@objc
class GridViewAddItem: NSObject, OECoverGridDataSourceItem {
    
    override func imageUID() -> String! {
        return "1337"
    }
    
    override func imageRepresentationType() -> String! {
        return IKImageBrowserNSImageRepresentationType
    }
    
    override func imageRepresentation() -> AnyObject! {
        return NSImage(named: "NewSubscription")
    }
    
    override func imageTitle() -> String! {
        return "Add Shows"
    }
    
    override func imageSubtitle() -> String! {
        return ""
    }
    
    func gridStatus() -> Int {
        return 0 //OEGridViewCellIndicationTypeNone
    }
    
    func gridRating() -> UInt {
        return 0
    }
    
    func setGridTitle(title: String!) {}
    
    func setGridRating(newRating: UInt) {}
    
    func shouldIndicateDeletable() -> Bool {
        return false
    }
    
    func shouldIndicateDownloadable() -> Bool {
        return false
    }
}
