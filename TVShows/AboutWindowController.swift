//
//  AboutWindowController.swift
//  TVShows
//
//  Created by Lucas Casteletti on 1/25/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.titlebarAppearsTransparent = true
        self.window?.movableByWindowBackground = true
        self.window?.titleVisibility = NSWindowTitleVisibility.Hidden
    }
    
    @IBAction func showLicense(sender: AnyObject) {
        
    }
    
    @IBAction func showAcknowledgements(sender: AnyObject) {
        
    }
    
}
