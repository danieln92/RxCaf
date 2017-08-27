//
//  CAFMessage.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/25/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation

public protocol CAFMessageType {
    var unauthorizedMessage : String { get }
    var objectMappingFailedCode : Int { get }
    var objectMappingFailedMessage : String { get }
    var messageLibrary : [Int:String] { get }
}

extension CAFMessageType {
    public var unauthorizedMessage : String {
        return "UNAUTHORIZED"
    }
    
    public var objectMappingFailedCode : Int {
        return -1
    }
    
    public var objectMappingFailedMessage : String {
        return "Found nil when trying to perform object mapping"
    }
    
    public var messageLibrary : [Int:String] {
        return [:]
    }
}

class CAFMessage : CAFMessageType {
}
