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
    
    var cellSizeCache = [Int: CGSize]()
    var minCellSizeHeight = CGFloat.max
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if let cachedSize = self.cellSizeCache[row] {
            return cachedSize.height
        }
        
        if let tableColumn = tableView.tableColumns.first as? NSTableColumn {
            if let cellView = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as? NSTableCellView {
                if let textField = cellView.textField {
                    if let objectValues = self.arrayController?.content as? [LocalizedString] {

                        let cellRect = cellView.frame
                        self.minCellSizeHeight = min(self.minCellSizeHeight, CGRectGetHeight(cellRect))
                        
                        let nibTextWidth = CGRectGetWidth(textField.frame)
                        let nibTextInset = CGRectGetWidth(cellRect) - nibTextWidth
                        let preferredTextWidth = tableColumn.width - nibTextInset
                        textField.preferredMaxLayoutWidth = preferredTextWidth
                        
                        cellView.objectValue = objectValues[row]
                        cellView.needsLayout = true
                        cellView.layoutSubtreeIfNeeded()
                        
                        let cellSize = cellView.fittingSize
                        self.cellSizeCache[row] = cellSize
                        return cellSize.height
                    }
                }
            }
        }
        return tableView.rowHeight
    }
    
    func tableViewColumnDidResize(notification: NSNotification) {
        if let tableView = notification.object as? NSTableView {
            if let newColumnWidth = (notification.userInfo?["NSTableColumn"] as? NSTableColumn)?.width {
                if let oldColumnWidth = notification.userInfo?["NSOldWidth"] as? CGFloat {
                    
                    let invalidRows = NSMutableIndexSet()
                    for (row, cellSize) in self.cellSizeCache {
                        
                        if newColumnWidth > oldColumnWidth { // |     -> |
                            if cellSize.height > self.minCellSizeHeight { // multiline may fit into the new width
                                invalidRows.addIndex(row)
                            }
                        }
                        else { // |     | <-
                            if newColumnWidth < cellSize.width { // column width is less than already taken space
                                invalidRows.addIndex(row)
                            }
                        }
                    }
                    
                    if invalidRows.count > 0 {
                        invalidRows.enumerateIndexesUsingBlock { invalidRow, _ in
                            self.cellSizeCache[invalidRow] = nil
                        }
                        
                        NSAnimationContext.beginGrouping()
                        NSAnimationContext.currentContext().duration = 0.0
                        tableView.noteHeightOfRowsWithIndexesChanged(invalidRows)
                        NSAnimationContext.endGrouping()
                    }
                }
            }
        }
    }
}
