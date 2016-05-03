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

@IBDesignable
class MainWindowTitlebarBackgroundView: NSView {
    
    let gradientColor = NSColor(deviceWhite: 0.15, alpha: 1.0)
    let gradientColor2 = NSColor(deviceWhite: 0.20, alpha: 1.0)
    
    override func drawRect(dirtyRect: NSRect) {
        let gradient = NSGradient(startingColor: gradientColor, endingColor: gradientColor2)
        
        gradient?.drawInRect(self.bounds, angle: 90.0)
    }
    
}
