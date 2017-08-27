//
//  APIPagination.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/27/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol PaginationType {
    var maxId : Int? {get set}
    var sinceId : Int? {get set}
    var count : Int? {get set}
    var page : Int? {get set}
    var total : Int? {get set}
    
    func nextSinceId() -> PaginationType
    func nextMaxId() -> PaginationType
    func toDictionary() -> [String: Any]
}

open class Pagination : PaginationType, Mappable {
    public var maxId : Int?
    public var sinceId : Int?
    public var count : Int?
    public var page : Int?
    public var total : Int?
    
    private init(count: Int, maxId: Int) {
        self.count = count
        self.maxId = maxId
    }
    
    private init(count: Int, sinceId: Int) {
        self.count = count
        self.sinceId = sinceId
    }
    
    public func nextSinceId() -> PaginationType {
        guard let count = self.count, let maxId = self.maxId else {
            return Pagination()
        }
        return Pagination(count: count, sinceId: maxId + 1)
    }
    
    public func nextMaxId() -> PaginationType {
        guard let count = self.count, let sinceId = self.sinceId, sinceId > 1 else {
            return Pagination()
        }
        return Pagination(count: count, maxId: sinceId - 1)
    }
    
    public init() {}
    
    public init(count: Int) {
        self.count = count
    }
    
    required public init? (map: Map) {
        
    }
    
    open func mapping(map: Map) {
        maxId       <- map["maxId"]
        sinceId     <- map["sinceId"]
        count       <- map["count"]
        page        <- map["page"]
        total       <- map["total"]
    }
    
    public func toDictionary() -> [String: Any] {
        var result : [String: Any] = [:]
        if let maxId = maxId {
            result["maxId"] = maxId
        }
        
        if let sinceId = sinceId {
            result["sinceId"] = sinceId
        }
        
        if let count = count {
            result["count"] = count
        }
        
        if let page = page {
            result["page"] = page
        }
        
        if let total = total {
            result["total"] = total
        }
        
        return result
    }
}
