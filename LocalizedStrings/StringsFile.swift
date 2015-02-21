//
//  StringsFile.swift
//  LocalizedStrings
//
//  Created by Vadim Shpakovski on 2/20/15.
//  Copyright (c) 2015 Vadim Shpakovski. All rights reserved.
//

import Foundation

enum Encoding {
    case UTF8
    case UTF16
}

extension Encoding {
    var stringRepresentation: String {
        switch self {
        case .UTF8:
            return "UTF-8";
        case .UTF16:
            return "UTF-16";
        }
    }
}

class StringsFile {
    
    let encoding: Encoding
    let localizedStrings: [LocalizedString]
    
    init(contents: String?, encoding: Encoding) {
        self.encoding = .UTF8
        
        var localizedStrings: [LocalizedString] = []
        if let contents = contents {
            let nsstring = contents as NSString
            
            let OneLinePattern = "\\s*\\\"(.+)\\\"\\s*=\\s*\\\"(.+)\\\";\\s*//\\s*(.*)\\s*"
            var error: NSError?
            if let regex = NSRegularExpression(pattern: OneLinePattern, options: nil, error: &error) {
                regex.enumerateMatchesInString(nsstring, options: nil, range: NSMakeRange(0, nsstring.length)) { (textCheckingResult, flags, stop) -> Void in
                    
                    let source = nsstring.substringWithRange(textCheckingResult.range) as NSString
                    let key = textCheckingResult.rangeAtIndex(1)
                    let value = textCheckingResult.rangeAtIndex(2)
                    let comment = textCheckingResult.rangeAtIndex(3)
                    let localized = LocalizedString(sourceString: source, keyRange: key, valueRange: value, commentRange: comment)
                    
                    localizedStrings.append(localized)
                }
            }
        }
        self.localizedStrings = localizedStrings
    }
    
    convenience init() {
        self.init(contents: nil, encoding: .UTF8)
    }
    
    convenience init?(url: NSURL, error: NSErrorPointer) {
        
        var enc = NSUTF8StringEncoding
        if let string = NSString(contentsOfURL: url, usedEncoding: &enc, error: error) {
            switch enc {
                
            case NSUTF8StringEncoding:
                self.init(contents: string, encoding: .UTF8)
                
            case NSUTF16StringEncoding:
                self.init(contents: string, encoding: .UTF16)
                
            default:
                self.init()
                return nil
            }
        }
        else {
            self.init()
            return nil
        }
    }
    
    func dataRepresentation() -> NSData? {
        var contents = "Hello";
        switch encoding {
        case .UTF8:
            return contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        case .UTF16:
            return contents.dataUsingEncoding(NSUTF16StringEncoding, allowLossyConversion: false)
        }
    }
}
