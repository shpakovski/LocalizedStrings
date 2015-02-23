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
    
    struct SearchMatch {
        let stringPattern: StringPattern
        let textCheckingResult: NSTextCheckingResult
    }
    
    class func arrayFromNSString(contents: NSString) -> [LocalizedString] {
        
        var localizedStrings: [LocalizedString] = []

        var searchRange = NSMakeRange(0, contents.length)
        while searchRange.location < NSMaxRange(searchRange) {
        
            var matches = StringPatterns.reduce([SearchMatch]()) { (var matches, stringPattern) -> [SearchMatch] in
                if let textCheckingResult = stringPattern.expression.firstMatchInString(contents, options: nil, range: searchRange) {
                    matches.append(SearchMatch(stringPattern: stringPattern, textCheckingResult: textCheckingResult))
                }
                return matches
            }

            if matches.count == 0 {
                break
            }
            
            var bestMatch = matches.removeAtIndex(0)
            bestMatch = matches.reduce(bestMatch) { (bestMatch, nextMatch) -> SearchMatch in
                return nextMatch.textCheckingResult.range.location < bestMatch.textCheckingResult.range.location ? nextMatch : bestMatch
            }
            
            let match = bestMatch.textCheckingResult
            
            let sourceRange = match.range
            let source = contents.substringWithRange(sourceRange) as NSString
            var keyRange = match.rangeAtIndex(bestMatch.stringPattern.keyRangePosition)
            keyRange.location -= sourceRange.location
            var valueRange = match.rangeAtIndex(bestMatch.stringPattern.valueRangePosition)
            valueRange.location -= sourceRange.location
            
            var commentRange = NSMakeRange(NSNotFound, 0)
            if bestMatch.stringPattern.commentRangePosition != NSNotFound {
                commentRange = match.rangeAtIndex(bestMatch.stringPattern.commentRangePosition)
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
