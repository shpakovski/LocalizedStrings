import Foundation
import Cocoa

class LocalizedString: NSObject {
    
    let sourceString: NSString
    let keyRange: NSRange
    let valueRange: NSRange
    var commentRange: NSRange?
    
    init(source sourceString: NSString, key keyRange: NSRange, value valueRange: NSRange, comment commentRange: NSRange) {
        self.sourceString = sourceString
        self.keyRange = keyRange
        self.valueRange = valueRange
        self.commentRange = commentRange
    }
    
    lazy var KeyAttributes: [NSObject : AnyObject] = {
        let smallFontSize = NSFont.systemFontSizeForControlSize(.SmallControlSize)
        if let smallFixedFont = NSFont.userFixedPitchFontOfSize(smallFontSize) {
            return [NSFontAttributeName: smallFixedFont]
        }
        let smallBoldFont = NSFont.boldSystemFontOfSize(smallFontSize)
        return [NSFontAttributeName: smallBoldFont]
    }()

    lazy var ValueAttributes: [NSObject : AnyObject] = {
        let smallRegularFont = NSFont.systemFontOfSize(NSFont.systemFontSizeForControlSize(.SmallControlSize))
        return [NSFontAttributeName: smallRegularFont]
    }()
    
    var attributedString: NSAttributedString {
        get {
            let key = self.sourceString.substringWithRange(keyRange)
            let attributedKey = NSAttributedString(string: key, attributes: KeyAttributes)
            let separator = NSAttributedString(string: " = ")
            let newline = NSAttributedString(string: "\n")
            let value = self.sourceString.substringWithRange(valueRange)
            let attributedValue = NSAttributedString(string: value, attributes: ValueAttributes)
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(attributedKey)
            result.appendAttributedString(separator)
            result.appendAttributedString(attributedValue)
            result.appendAttributedString(newline)
            result.appendAttributedString(attributedKey)
            result.appendAttributedString(separator)
            result.appendAttributedString(attributedValue)
            result.appendAttributedString(newline)
            result.appendAttributedString(attributedKey)
            result.appendAttributedString(separator)
            result.appendAttributedString(attributedValue)
            return result.copy() as NSAttributedString
        }
    }
}
