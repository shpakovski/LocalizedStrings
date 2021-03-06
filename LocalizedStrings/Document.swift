//
//  Document.swift
//  LocalizedStrings
//
//  Created by Vadim Shpakovski on 2/20/15.
//  Copyright (c) 2015 Vadim Shpakovski. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        
        if self.stringsFile == nil {
            self.stringsFile = StringsFile()
        }
        
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as WindowController
        windowController.stringsFile = self.stringsFile
        self.addWindowController(windowController)
    }

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        return stringsFile?.dataRepresentation()
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//        return nil
    }
    
    var stringsFile: StringsFile? {
        didSet {
            if let windowController = self.windowControllers.first as? WindowController {
                windowController.stringsFile = self.stringsFile
            }
            self.undoManager?.registerUndoWithTarget(self, selector: "undoStringsFile:", object: oldValue)
        }
    }
    
    @IBAction func undoStringsFile(sender: AnyObject) {
        self.stringsFile = sender as? StringsFile
    }

    override func readFromURL(url: NSURL, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        self.undoManager?.disableUndoRegistration()
        self.stringsFile = StringsFile(url: url, error: outError)
        self.undoManager?.enableUndoRegistration()
        return self.stringsFile != nil
    }
    
//    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
            // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
            // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
            // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
//            outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//            return false
//    }
    
    @IBAction func userDidPressImportStrings(sender: AnyObject) {
        
        if let documentWindow = self.windowControllers.first?.window as? NSWindow {
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories = false
            openPanel.allowedFileTypes = ["strings"]
            openPanel.allowsOtherFileTypes = false
            openPanel.beginSheetModalForWindow(documentWindow) { response in
                if response == NSModalResponseOK {
                    if let stringsURL = openPanel.URL {
                        self.importStringsFromURL(stringsURL)
                    }
                }
            }
        }
    }
    
    func importStringsFromURL(stringsURL: NSURL) {
        var error: NSError?
        if let importedStringsFile = StringsFile(url: stringsURL, error: &error) {
            if let currentStringsFile = self.stringsFile {
                self.stringsFile = StringsFile.merge(currentStringsFile, with: importedStringsFile)
            }
            else {
                self.stringsFile = importedStringsFile
            }
        }
        else {
            println(error)
        }
    }
}
