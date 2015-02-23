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
