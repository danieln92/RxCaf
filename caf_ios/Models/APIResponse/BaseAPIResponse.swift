//
//  BaseAPIResponse.swift
//  RxCaf
//
//  Created by Duy Nguyen on 11/24/16.
//  Copyright © 2016 Duy Nguyen. All rights reserved.
//

import UIKit
import ObjectMapper

public protocol APIResponseType {
    var errors : [APIErrorType]? {get}
    var dataAsString : String? {get set}
    
    func isError() -> Bool
}


open class BaseAPIResponse : Mappable, APIResponseType {
    
    var _errors : [BaseAPIError]?
    public var errors : [APIErrorType]? {
        get {
            return _errors
        }
    }
    public var dataAsString : String?
    
    public var paging : Pagination?
    
    required public init? (map: Map) {
    }
    
    open func mapping(map: Map) {
        _errors          <- map["errors"]
        dataAsString    <- map["data"]
        paging          <- map["pagination"]
    }
    
    public func isError() -> Bool {
        return errors != nil && (errors?.count)! > 0
    }
}

open class APIResponse<T : Mappable> : BaseAPIResponse {
    
    public var data : T?
    public var datas : [T]?
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        data            <- map["data"]
        datas           <- map["data"]
    }
}


