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
    
    let original: String?
    let encoding: Encoding
    
    init(original: String?, encoding: Encoding) {
        self.original = original
        self.encoding = .UTF8
    }
    
    convenience init() {
        self.init(original: nil, encoding: .UTF8)
    }
    
    convenience init(data: NSData) {
        if let string = NSString(data: data, encoding: NSUTF16StringEncoding) {
            self.init(original: string, encoding: .UTF16)
        }
        else if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
            self.init(original: string, encoding: .UTF8)
        }
        else {
            self.init()
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
