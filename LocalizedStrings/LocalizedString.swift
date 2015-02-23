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

var RegularExpressions: [(NSRegularExpression, Int, Int, Int)] = { // regexp, key-index, value-index, comment-index or NSNotFound
    
    let patterns = [
        
        // \s*/\*+\s*(.*)\s*\*+/\s*\"(.*)\"\s*=\s*\"(.*)\";\s*
        ("\\s*/\\*+\\s*(.*)\\s*\\*+/\\s*\\\"(.*)\\\"\\s*=\\s*\\\"(.*)\\\";\\s*", 2, 3, 1), // /** comment **/ "key" = "value";
        
        // \s*\"(.+)\"\s*=\s*\"(.+)\";\s*//\s*(.*)\s*
        ("\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*//\\s*(.*)\\s*", 1, 2, 3), // "key" = "value"; // comment
        
        // \s*\"(.+)\"\s*=\s*\"(.+)\";\s*
        ("\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*", 1, 2, NSNotFound)] // "key" = "value";
    
    return patterns.reduce([NSRegularExpression, Int, Int, Int]()) { (var expressions, pattern) -> [(NSRegularExpression, Int, Int, Int)] in
        var error: NSError?
        if let expression = NSRegularExpression(pattern: pattern.0, options: nil, error: &error) {
            expressions.append((expression.0, pattern.1, pattern.2, pattern.3))
        }
        else {
            println(error)
        }
        return expressions
    }
}()

extension LocalizedString {
    class func arrayFromNSString(contents: NSString) -> [LocalizedString] {
        
        var localizedStrings: [LocalizedString] = []
        
        var searchRange = NSMakeRange(0, contents.length)
        while searchRange.location < NSMaxRange(searchRange) {
        
            let matches = RegularExpressions.map { (expression) -> (NSTextCheckingResult?, Int, Int, Int) in
                return (expression.0.firstMatchInString(contents, options: nil, range: searchRange), expression.1, expression.2, expression.3)
            }.filter { $0.0 != nil }.map { ($0.0!, $0.1, $0.2, $0.3) }
            
            if matches.count == 0 {
                break
            }
            
            let bestMatch = matches.reduce(matches.first!) { (bestMatch, match) -> (NSTextCheckingResult, Int, Int, Int) in
                return match.0.range.location < bestMatch.0.range.location ? match : bestMatch
            }
            
            let match = bestMatch.0
            let keyRangePosition = bestMatch.1
            let valueRangePosition = bestMatch.2
            let commentRangePosition = bestMatch.3
            
            let sourceRange = match.range
            let source = contents.substringWithRange(sourceRange) as NSString
            var keyRange = match.rangeAtIndex(keyRangePosition)
            keyRange.location -= sourceRange.location
            var valueRange = match.rangeAtIndex(valueRangePosition)
            valueRange.location -= sourceRange.location
            
            var commentRange = NSMakeRange(NSNotFound, 0)
            if commentRangePosition != NSNotFound {
                commentRange = match.rangeAtIndex(commentRangePosition)
                commentRange.location -= sourceRange.location
            }
            let localized = LocalizedString(source: source, key: keyRange, value: valueRange, comment: commentRange, modified: false)
            
            localizedStrings.append(localized)
            
            searchRange.location += source.length
            searchRange.length -= source.length
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
