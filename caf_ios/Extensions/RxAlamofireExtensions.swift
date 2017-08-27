//
//  RxAlamofireUtils.swift
//
//  Created by Duy Nguyen on 2/20/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation
import RxAlamofire
import ObjectMapper
#if !RX_NO_MODULE
    import RxSwift
#endif

public extension ObservableType {
    func mapObject<T: Mappable>(type: T.Type) -> Observable<T> {
        return flatMap { data -> Observable<T> in
            let json = data
            guard let object = Mapper<T>().map(JSONObject : json) else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't perform mapping"]
                )
            }
            
            return Observable.just(object)
        }
    }
    
    func mapArray<T: Mappable>(type: T.Type) -> Observable<[T]> {
        return flatMap { data -> Observable<[T]> in
            let json = data
            let objects = Mapper<T>().mapArray(JSONArray: json as! [[String : Any]])
            return Observable.just(objects)
        }
    }
    
}

