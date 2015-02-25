//
//  StringPattern.swift
//  LocalizedStrings
//
//  Created by Vadim Shpakovski on 2/23/15.
//  Copyright (c) 2015 Vadim Shpakovski. All rights reserved.
//

import Foundation

typealias RangeIndex = Int

enum OptionalRangeIndex {
    case At(RangeIndex)
    case NotPresented
}

struct StringPattern {
    let expression: NSRegularExpression
    let keyRangeIndex: RangeIndex
    let valueRangeIndex: RangeIndex
    let optionalCommentRangeIndex: OptionalRangeIndex
    
    init(pattern: String, key: RangeIndex, value: RangeIndex, optionalComment: OptionalRangeIndex) {
        self.expression = NSRegularExpression(pattern: pattern, options: nil, error: nil)! // Invalid pattern must crash the app
        self.keyRangeIndex = key
        self.valueRangeIndex = value
        self.optionalCommentRangeIndex = optionalComment
    }
}

let stringPatterns: [StringPattern] = {
    return [                 // \s*/\*+\s*(.*)\s*\*+/\s*\"(.*)\"\s*=\s*\"(.*)\";\s*                    /** comment **/ "key" = "value";
        StringPattern(pattern: "\\s*/\\*+\\s*(.*)\\s*\\*+/\\s*\\\"(.*)\\\"\\s*=\\s*\\\"(.*)\\\";\\s*", key: 2, value: 3, optionalComment: .At(1)),
                             // \s*\"(.+)\"\s*=\s*\"(.+)\";\s*//\s*(.*)\s*                 "key" = "value"; // comment
        StringPattern(pattern: "\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*//\\s*(.*)\\s*", key: 1, value: 2, optionalComment: .At(3)),
                             // \s*\"(.+)\"\s*=\s*\"(.+)\";\s*               "key" = "value";
        StringPattern(pattern: "\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*", key: 1, value: 2, optionalComment: .NotPresented)]
}()

struct StringPatternMatch {
    let stringPattern: StringPattern
    let textCheckingResult: NSTextCheckingResult
}

extension NSString {
    
    func firstPatternMatchInRange(range: NSRange) -> StringPatternMatch? {
        
        var availableMatches = stringPatterns.reduce([StringPatternMatch]()) { (var matches, stringPattern) -> [StringPatternMatch] in
            if let match = stringPattern.expression.firstMatchInString(self, options: nil, range: range) {
                matches.append(StringPatternMatch(stringPattern: stringPattern, textCheckingResult: match))
            }
            return matches
        }
        
        if var bestMatch = availableMatches.first {
            for nextMatch in dropFirst(availableMatches) {
                if nextMatch.textCheckingResult.range.location < bestMatch.textCheckingResult.range.location {
                    bestMatch = nextMatch
                }
            }
            return bestMatch
        }
        return nil
    }

    func firstLocalizedStringInRange(searchRange: NSRange) -> LocalizedString? {
        if let patternMatch = self.firstPatternMatchInRange(searchRange) {
            
            let (textCheckingResult, stringPattern) = (patternMatch.textCheckingResult, patternMatch.stringPattern)
            
            let patternRange = textCheckingResult.range
            let source = self.substringWithRange(patternRange) as NSString
            
            var (keyRange, valueRange) = (textCheckingResult.rangeAtIndex(stringPattern.keyRangeIndex), textCheckingResult.rangeAtIndex(stringPattern.valueRangeIndex))
            keyRange.location -= patternRange.location
            valueRange.location -= patternRange.location

            let commentRange: NSRange = {
                switch stringPattern.optionalCommentRangeIndex {
                case .At(let rangeIndex):
                    var commentRange = textCheckingResult.rangeAtIndex(rangeIndex)
                    commentRange.location -= patternRange.location
                    return commentRange
                case .NotPresented:
                    return NSMakeRange(NSNotFound, 0)
                }
            }()
            
            return LocalizedString(source: source, key: keyRange, value: valueRange, comment: commentRange, modified: false)
        }
        else {
            return nil
        }
    }
}
