//
//  LocalStorageManagerType.swift
//  RxCaf
//
//  Created by Duy Nguyen on 5/15/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

public protocol LocalStorageManagerType {
    
    /// GET Objects from local storage
    ///
    /// - Parameters:
    ///   - filter: Optional - Filter query ( NSPredicate )
    ///   - sorted: Optional - Sort query. Value1 - keyToSortedBy, Value2 - isAscending
    /// - Returns: Objects that matched filter and sorted.
    func getObjects<T>(_ filter: String?, _ sorted: (String,Bool)?) -> [T]
    func getObject<T>(_ id: String) -> T?
    func saveObjects(_ objects : [Any])
    func updateObjects(_ objects : [Any], keyValue: (String,Any))
    func deleteObject(_ object : Any)
    func deleteObjects(_ objects : [Any])
    
}
