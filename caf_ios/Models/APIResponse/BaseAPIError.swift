//
//  BaseError.swift
//  RxCaf
//
//  Created by Duy Nguyen on 11/24/16.
//  Copyright © 2016 Duy Nguyen. All rights reserved.
//

import UIKit
import ObjectMapper

public protocol APIErrorType {
    var errorCode : Int? {get set}
    var errorMessage : String? {get set}
    
    init(errorCode : Int, errorMessage : String)
}

open class BaseAPIError: Mappable, APIErrorType {
    public var errorCode: Int?
    public var errorMessage : String?
    
    required public init(errorCode : Int, errorMessage : String) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        errorCode <- ( map["errorCode"], ErrorCodeTransform() )
        errorMessage <- map["errorMessage"]
    }
}

class ErrorCodeTransform: TransformType {
    
    typealias Object = Int
    typealias JSON = String
    
    func transformFromJSON(_ value: Any?) -> Int? {
        
        if let value = value as? String {
            return Int(value)
        }
        if let value = value as? Int {
            return value
        }
        return nil
    }
    
    func transformToJSON(_ value: Int?) -> String? {
        //never gonna happen this line of code
        return ""
    }
}


