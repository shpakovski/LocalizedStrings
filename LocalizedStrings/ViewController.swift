//
//  ViewController.swift
//  LocalizedStrings
//
//  Created by Vadim Shpakovski on 2/20/15.
//  Copyright (c) 2015 Vadim Shpakovski. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override var representedObject: AnyObject? {
        didSet {
            if self.viewLoaded {
                self.willChangeValueForKey("encodingStringRepresentation")
                self.didChangeValueForKey("encodingStringRepresentation")
                
                self.willChangeValueForKey("localizedStrings")
                self.didChangeValueForKey("localizedStrings")
            }
        }
    }
    
    var encodingStringRepresentation: String? {
        let stringsFile = representedObject as? StringsFile
        return stringsFile?.encoding.stringRepresentation
    }
    
    var localizedStrings: [LocalizedString]? {
        let stringsFile = representedObject as? StringsFile
        return stringsFile?.localizedStrings
    }
    
    @IBOutlet var arrayController: NSArrayController?
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if let tableColumn = tableView.tableColumns.first as? NSTableColumn {
            if let cellView = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as? NSTableCellView {
                if let objectValues = self.arrayController?.content as? [LocalizedString] {
                    
                    cellView.objectValue = objectValues[row]
                    cellView.needsLayout = true
                    cellView.layoutSubtreeIfNeeded()
                    
                    let cellSize = cellView.fittingSize
                    return cellSize.height
                }
            }
        }
        return tableView.rowHeight
    }
    
    func tableViewColumnDidResize(notification: NSNotification) {
        if let tableView = notification.object as? NSTableView {
            if let bounds = tableView.enclosingScrollView?.contentView.bounds {
                let visibleRows = tableView.rowsInRect(bounds)
                let indexes = NSIndexSet(indexesInRange: visibleRows)
                
                NSAnimationContext.beginGrouping()
                NSAnimationContext.currentContext().duration = 0.0
                tableView.noteHeightOfRowsWithIndexesChanged(indexes)
                NSAnimationContext.endGrouping()
            }
        }
    }
}
