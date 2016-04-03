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

class AboutWindowController: NSWindowController {
    
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appVersion: NSTextField!
    
    @IBOutlet var textWindow: NSWindow!
    @IBOutlet var textView: NSTextView!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.titlebarAppearsTransparent = true
        self.window?.movableByWindowBackground = true
        self.window?.titleVisibility = NSWindowTitleVisibility.Hidden
        
        let bundle = NSBundle.mainBundle()
        
        // App name
        appName.stringValue = bundle.objectForInfoDictionaryKey("CFBundleName") as! String
        
        // App version
        let version = bundle.objectForInfoDictionaryKey("CFBundleVersion") as! String
        let shortVersion = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        appVersion.stringValue = "Version \(version) (Build \(shortVersion))";
    }
    
    @IBAction func showLicense(sender: AnyObject) {
        let licensePath = NSBundle.mainBundle().pathForResource("LICENSE", ofType: "txt")
        let data = NSData.init(contentsOfFile: licensePath!)
        
        do {
            let astring = try NSAttributedString.init(data: data!, options: [:], documentAttributes: nil)
            textView.textStorage?.setAttributedString(astring)
            
            textWindow.title = "License"
            textWindow.makeKeyAndOrderFront(sender)
        } catch {
            
        }
    }
    
    @IBAction func showAcknowledgements(sender: AnyObject) {
        let licensePath = NSBundle.mainBundle().pathForResource("Acknowledgments", ofType: "rtf")
        let data = NSData.init(contentsOfFile: licensePath!)
        let astring = NSAttributedString.init(RTF: data!, documentAttributes: nil);
        
        textView.textStorage?.setAttributedString(astring!)
        
        textWindow.title = "Acknowledgments"
        textWindow.makeKeyAndOrderFront(sender)
    }
    
}
