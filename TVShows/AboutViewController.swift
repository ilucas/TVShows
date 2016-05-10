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

class AboutViewController: NSViewController {
    
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appVersion: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle.mainBundle()
        
        // App name
        appName.stringValue = bundle.objectForInfoDictionaryKey("CFBundleName") as! String
        
        // App version
        let version = bundle.objectForInfoDictionaryKey("CFBundleVersion") as! String
        let shortVersion = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        appVersion.stringValue = "Version \(version) (Build \(shortVersion))"
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        let licenseViewController = segue.destinationController as! LicenseViewController
        let bundle = NSBundle.mainBundle()
        
        if (segue.identifier == "LicenseSegue") {
            licenseViewController.content = bundle.pathForResource("LICENSE", ofType: "txt")!
            licenseViewController.title = "License"
        } else if (segue.identifier == "AcknowledgementSegue") {
            licenseViewController.content = bundle.pathForResource("Acknowledgments", ofType: "rtf")!
            licenseViewController.title = "Acknowledgments"
        }
    }
}
