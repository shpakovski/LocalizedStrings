import Foundation
import Cocoa

class LocalizedString: NSObject {
    
    let sourceString: NSString
    let keyRange: NSRange
    let valueRange: NSRange
    let commentRange: NSRange
    let modified: Bool
    
    init(source sourceString: NSString, key keyRange: NSRange, value valueRange: NSRange, comment commentRange: NSRange, modified: Bool) {
        self.sourceString = sourceString
        self.keyRange = keyRange
        self.valueRange = valueRange
        self.commentRange = commentRange
        self.modified = modified
    }
}

// MARK:

var KeyAttributes: [NSObject : AnyObject] = {
    let smallFontSize = NSFont.systemFontSizeForControlSize(.SmallControlSize)
    if let smallFixedFont = NSFont.userFixedPitchFontOfSize(smallFontSize) {
        return [NSFontAttributeName: smallFixedFont]
    }
    let smallBoldFont = NSFont.systemFontOfSize(smallFontSize)
    return [NSFontAttributeName: smallBoldFont]
}()

var ValueAttributes: [NSObject : AnyObject] = {
    let smallRegularFont = NSFont.systemFontOfSize(NSFont.systemFontSizeForControlSize(.SmallControlSize))
    return [NSFontAttributeName: smallRegularFont]
}()

var ModifiedValueAttributes: [NSObject : AnyObject] = {
    let smallBoldFont = NSFont.boldSystemFontOfSize(NSFont.systemFontSizeForControlSize(.SmallControlSize))
    return [NSFontAttributeName: smallBoldFont]
}()

// MARK:

extension LocalizedString {
    
    var attributedString: NSAttributedString {
        get {
            let key = self.sourceString.substringWithRange(keyRange)
            let attributedKey = NSAttributedString(string: key, attributes: KeyAttributes)
            let separator = NSAttributedString(string: " = ")
            let value = self.sourceString.substringWithRange(valueRange)
            let attributedValue = NSAttributedString(string: value, attributes: self.modified ? ModifiedValueAttributes : ValueAttributes)
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(attributedKey)
            result.appendAttributedString(separator)
            result.appendAttributedString(attributedValue)
            return result.copy() as NSAttributedString
        }
    }
    
    var keyString: String {
        get {
            return sourceString.substringWithRange(keyRange)
        }
    }
    
    var valueString: String {
        get {
            return sourceString.substringWithRange(valueRange)
        }
    }
    
    var resultString: String {
        get {
            return self.sourceString;
        }
    }
}

// MARK:

extension LocalizedString {
    class func arrayFromNSString(contents: NSString) -> [LocalizedString] {
        
        var localizedStrings: [LocalizedString] = []
        let OneLinePattern = "\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*//\\s*(.*)\\s*"
        var error: NSError?
        if let regex = NSRegularExpression(pattern: OneLinePattern, options: nil, error: &error) {
            var offset = 0
            regex.enumerateMatchesInString(contents, options: nil, range: NSMakeRange(0, contents.length)) { (textCheckingResult, flags, stop) -> Void in
                
                let source = contents.substringWithRange(textCheckingResult.range) as NSString
                var key = textCheckingResult.rangeAtIndex(1)
                key.location -= offset
                var value = textCheckingResult.rangeAtIndex(2)
                value.location -= offset
                var comment = textCheckingResult.rangeAtIndex(3)
                comment.location -= offset
                let localized = LocalizedString(source: source, key: key, value: value, comment: comment, modified: false)
                
                localizedStrings.append(localized)
                
                offset += source.length
            }
        }
        return localizedStrings
    }
    
    class func merge(string1: LocalizedString, with string2: LocalizedString) -> LocalizedString {
        assert(string1.keyString == string2.keyString, "Localized strings must have the same key")
        if string1.valueString == string2.valueString {
            return string1.copy() as LocalizedString
        }
        else {
            return LocalizedString(source: string2.sourceString, key: string2.keyRange, value: string2.valueRange, comment: string2.commentRange, modified: true)
        }
    }
}

extension LocalizedString: NSCopying {
    func copyWithZone(zone: NSZone) -> AnyObject {
        return LocalizedString(source: self.sourceString, key: self.keyRange, value: self.valueRange, comment: self.commentRange, modified: self.modified)
    }
}
