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
    
    init(localizedStrings: [LocalizedString], encoding: Encoding) {
        self.encoding = .UTF8
        self.localizedStrings = localizedStrings
    }
    
    convenience init() {
        self.init(localizedStrings: [LocalizedString](), encoding: .UTF8)
    }
    
    convenience init?(url: NSURL, error: NSErrorPointer) {
        
        var enc = NSUTF8StringEncoding
        if let string = NSString(contentsOfURL: url, usedEncoding: &enc, error: error) {
            
            let localizedStrings = LocalizedString.arrayFromNSString(string)
            switch enc {
                
            case NSUTF8StringEncoding:
                self.init(localizedStrings: localizedStrings, encoding: .UTF8)
                
            case NSUTF16StringEncoding:
                self.init(localizedStrings: localizedStrings, encoding: .UTF16)
                
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

extension StringsFile {
    class func merge(stringsFile1: StringsFile, with stringsFile2: StringsFile) -> StringsFile {

        var bucket2 = [String: LocalizedString]()
        for localizedString2 in stringsFile2.localizedStrings {
            bucket2[localizedString2.keyString] = localizedString2
        }
        
        let resultStrings = stringsFile1.localizedStrings.map { (localizedString1) -> LocalizedString in
            if let localizedString2 = bucket2[localizedString1.keyString] {
                return LocalizedString.merge(localizedString1, with: localizedString2)
            }
            else {
                return localizedString1
            }
        }
        return StringsFile(localizedStrings: resultStrings, encoding: stringsFile1.encoding)
    }
}
