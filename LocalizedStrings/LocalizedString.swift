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

struct StringPattern {
    let expression: NSRegularExpression
    let keyRangePosition: Int
    let valueRangePosition: Int
    let commentRangePosition: Int // may be NSNotFound
}
let StringPatterns: [StringPattern] = {

    typealias RawStringPattern = (String, Int, Int, Int) // regexp, key-index, value-index, comment-index or NSNotFound
    let knownRawPatterns: [RawStringPattern] = {
        return [
            // \s*/\*+\s*(.*)\s*\*+/\s*\"(.*)\"\s*=\s*\"(.*)\";\s*
            ("\\s*/\\*+\\s*(.*)\\s*\\*+/\\s*\\\"(.*)\\\"\\s*=\\s*\\\"(.*)\\\";\\s*", 2, 3, 1), // /** comment **/ "key" = "value";
            // \s*\"(.+)\"\s*=\s*\"(.+)\";\s*//\s*(.*)\s*
            ("\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*//\\s*(.*)\\s*", 1, 2, 3), // "key" = "value"; // comment
            // \s*\"(.+)\"\s*=\s*\"(.+)\";\s*
            ("\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*", 1, 2, NSNotFound)] // "key" = "value";
    }()
    
    return knownRawPatterns.reduce([StringPattern]()) { (var stringPatterns, raw) -> [StringPattern] in
        var error: NSError?
        if let expression = NSRegularExpression(pattern: raw.0, options: nil, error: &error) {
            stringPatterns.append(StringPattern(expression: expression, keyRangePosition: raw.1, valueRangePosition: raw.2, commentRangePosition: raw.3))
        }
        else {
            println(error)
        }
        return stringPatterns
    }
}()

extension LocalizedString {
    class func arrayFromNSString(contents: NSString) -> [LocalizedString] {
        
        var localizedStrings: [LocalizedString] = []

        typealias SearchMatch = (StringPattern, NSTextCheckingResult)
        
        var searchRange = NSMakeRange(0, contents.length)
        while searchRange.location < NSMaxRange(searchRange) {
        
            var matches = StringPatterns.reduce([SearchMatch]()) { (var matches, stringPattern) -> [SearchMatch] in
                if let match = stringPattern.expression.firstMatchInString(contents, options: nil, range: searchRange) {
                    matches.append((stringPattern, match))
                }
                return matches
            }

            if matches.count == 0 {
                break
            }
            
            var bestMatch = matches.removeAtIndex(0)
            bestMatch = matches.reduce(bestMatch) { (bestMatch, nextMatch) -> SearchMatch in
                return nextMatch.1.range.location < bestMatch.1.range.location ? nextMatch : bestMatch
            }
            
            let match = bestMatch.1
            
            let sourceRange = match.range
            let source = contents.substringWithRange(sourceRange) as NSString
            var keyRange = match.rangeAtIndex(bestMatch.0.keyRangePosition)
            keyRange.location -= sourceRange.location
            var valueRange = match.rangeAtIndex(bestMatch.0.valueRangePosition)
            valueRange.location -= sourceRange.location
            
            var commentRange = NSMakeRange(NSNotFound, 0)
            if bestMatch.0.commentRangePosition != NSNotFound {
                commentRange = match.rangeAtIndex(bestMatch.0.commentRangePosition)
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
