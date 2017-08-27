//
//  StringExtensions.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/22/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation

public extension String {

    public func generateUUID(_ fileExtension: String) -> String {
        let newFileExtension = fileExtension.characters.first == "." ? fileExtension : ("." + fileExtension)
        return ProcessInfo.processInfo.globallyUniqueString.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").lowercased().appending(newFileExtension)
    }

    public func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    public func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    public func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    public func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }

}
