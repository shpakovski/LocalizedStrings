//
//  WindowController.swift
//  LocalizedStrings
//
//  Created by Vadim Shpakovski on 2/20/15.
//  Copyright (c) 2015 Vadim Shpakovski. All rights reserved.
//

import Foundation
import Cocoa

class WindowController: NSWindowController {
    
    var stringsFile: StringsFile? {
        didSet {
            updateViewControllerContents()
        }
    }
    
    override var contentViewController: NSViewController? {
        didSet {
            updateViewControllerContents()
        }
    }
    
    func updateViewControllerContents() {
        let viewController = contentViewController as? ViewController
        viewController?.representedObject = stringsFile
    }
}
