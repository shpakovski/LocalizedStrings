//
//  StringPattern.swift
//  LocalizedStrings
//
//  Created by Vadim Shpakovski on 2/23/15.
//  Copyright (c) 2015 Vadim Shpakovski. All rights reserved.
//

import Foundation

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

struct StringPatternMatch {
    let stringPattern: StringPattern
    let match: NSTextCheckingResult
}

func firstPatternMatchInString(contents: NSString, #range: NSRange) -> StringPatternMatch? {
    
    var possibleStringMatches = StringPatterns.reduce([StringPatternMatch]()) { (var matches, stringPattern) -> [StringPatternMatch] in
        if let match = stringPattern.expression.firstMatchInString(contents, options: nil, range: range) {
            matches.append(StringPatternMatch(stringPattern: stringPattern, match: match))
        }
        return matches
    }
    
    if possibleStringMatches.count == 0 {
        return nil
    }
    
    var bestStringMatch = possibleStringMatches.removeAtIndex(0)
    bestStringMatch = possibleStringMatches.reduce(bestStringMatch) { (bestMatch, nextMatch) -> StringPatternMatch in
        return nextMatch.match.range.location < bestMatch.match.range.location ? nextMatch : bestMatch
    }
    return bestStringMatch
}
