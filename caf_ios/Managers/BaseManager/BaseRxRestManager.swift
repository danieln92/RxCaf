//
//  RxBaseRestService.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/25/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation
import RxAlamofire
import Alamofire
import ObjectMapper
#if !RX_NO_MODULE
    import RxSwift
#endif

open class BaseRxRestManager : RxRestManagerType {
    open var headers: [String : String]? = [:]
    open var token: String = ""
    open var baseURL: String = ""
    open var messageType : CAFMessageType {
        return CAFMessage()
    }
    
    public init() {}
    
    // MARK: - GET
    public func doGet<T : Mappable>(_ url:String) -> Observable<RxResult<[T]>> {
        return self.doGet(url, params: nil)
    }
    
    public func doGet<T : Mappable>(_ url:String) -> Observable<RxResult<T>> {
        return self.doGet(url, params: nil)
    }
    
    public func doGet(_ url: String) -> Observable<RxResult<String>> {
        return self.doGet(url, params : nil)
    }
    
    public func doGet<T: Mappable>(_ url:String, params: Mappable) -> Observable<RxResult<[T]>> {
        return self.doGet(url, params: params.toJSON())
    }
    
    public func doGet<T: Mappable>(_ url:String, params: Mappable) -> Observable<RxResult<T>> {
        return self.doGet(url, params: params.toJSON())
    }
    
    public func doGet(_ url: String, params: Mappable) -> Observable<RxResult<String>> {
        return self.doGet(url, params: params.toJSON())
    }
    
    //MARK: - POST
    public func doPostJSON<T : Mappable>(_ url : String) -> Observable<RxResult<T>> {
        return self.doPostJSON(url, data: nil)
    }
    
    public func doPostJSON<T : Mappable>(_ url : String) -> Observable<RxResult<[T]>> {
        return self.doPostJSON(url, data: nil)
    }
    
    public func doPostJSON(_ url : String)-> Observable<RxResult<String>> {
        return self.doPostJSON(url, data: nil)
    }
    
    public func doPostURLEncoded<T : Mappable>(_ url : String) -> Observable<RxResult<T>> {
        return self.doPostURLEncoded(url, data: nil)
    }
    
    public func doPostURLEncoded<T : Mappable>(_ url : String) -> Observable<RxResult<[T]>> {
        return self.doPostURLEncoded(url, data: nil)
    }
    
    public func doPostURLEncoded(_ url : String)-> Observable<RxResult<String>> {
        return self.doPostURLEncoded(url, data: nil)
    }
    
    public func doPostJSON<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<T>> {
        return self.doPostJSON(url, data: data.toJSON())
    }
    
    public func doPostJSON<T : Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<[T]>> {
        return self.doPostJSON(url, data: data.toJSON())
    }
    
    public func doPostJSON(_ url : String, data: Mappable)-> Observable<RxResult<String>> {
        return self.doPostJSON(url, data: data.toJSON())
    }
    
    public func doPostURLEncoded<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<T>> {
        return self.doPostURLEncoded(url, data: data.toJSON())
    }
    
    public func doPostURLEncoded<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<[T]>> {
        return self.doPostURLEncoded(url, data: data.toJSON())
    }
    
    public func doPostURLEncoded(_ url : String, data: Mappable)-> Observable<RxResult<String>> {
        return self.doPostURLEncoded(url, data: data.toJSON())
    }
    
    //MARK: - PUT
    public func doPutJSON<T : Mappable>(_ url : String) -> Observable<RxResult<T>> {
        return self.doPutJSON(url, data: nil)
    }
    
    public func doPutJSON<T : Mappable>(_ url : String) -> Observable<RxResult<[T]>> {
        return self.doPutJSON(url, data: nil)
    }
    
    public func doPutJSON(_ url : String)-> Observable<RxResult<String>> {
        return self.doPutJSON(url, data: nil)
    }
    
    public func doPutURLEncoded<T : Mappable>(_ url : String) -> Observable<RxResult<T>> {
        return self.doPutURLEncoded(url, data: nil)
    }
    
    public func doPutURLEncoded<T : Mappable>(_ url : String) -> Observable<RxResult<[T]>> {
        return self.doPutURLEncoded(url, data: nil)
    }
    
    public func doPutURLEncoded(_ url : String)-> Observable<RxResult<String>> {
        return self.doPutURLEncoded(url, data: nil)
    }
    
    public func doPutJSON<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<T>> {
        return self.doPutJSON(url, data: data.toJSON())
    }
    
    public func doPutJSON<T : Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<[T]>> {
        return self.doPutJSON(url, data: data.toJSON())
    }
    
    public func doPutJSON(_ url : String, data: Mappable)-> Observable<RxResult<String>> {
        return self.doPutJSON(url, data: data.toJSON())
    }
    
    public func doPutURLEncoded<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<T>> {
        return self.doPutURLEncoded(url, data: data.toJSON())
    }
    
    public func doPutURLEncoded<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<[T]>> {
        return self.doPutURLEncoded(url, data: data.toJSON())
    }
    
    public func doPutURLEncoded(_ url : String, data: Mappable)-> Observable<RxResult<String>> {
        return self.doPutURLEncoded(url, data: data.toJSON())
    }
    
    //MARK: - PATCH
    public func doPatchJSON<T : Mappable>(_ url : String) -> Observable<RxResult<T>> {
        return self.doPatchJSON(url, data: nil)
    }
    
    public func doPatchJSON<T : Mappable>(_ url : String) -> Observable<RxResult<[T]>> {
        return self.doPatchJSON(url, data: nil)
    }
    
    public func doPatchJSON(_ url : String)-> Observable<RxResult<String>> {
        return self.doPatchJSON(url, data: nil)
    }
    
    public func doPatchURLEncoded<T : Mappable>(_ url : String) -> Observable<RxResult<T>> {
        return self.doPatchURLEncoded(url, data: nil)
    }
    
    public func doPatchURLEncoded<T : Mappable>(_ url : String) -> Observable<RxResult<[T]>> {
        return self.doPatchURLEncoded(url, data: nil)
    }
    
    public func doPatchURLEncoded(_ url : String)-> Observable<RxResult<String>> {
        return self.doPatchURLEncoded(url, data: nil)
    }
    
    public func doPatchJSON<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<T>> {
        return self.doPatchJSON(url, data: data.toJSON())
    }
    
    public func doPatchJSON<T : Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<[T]>> {
        return self.doPatchJSON(url, data: data.toJSON())
    }
    
    public func doPatchJSON(_ url : String, data: Mappable)-> Observable<RxResult<String>> {
        return self.doPatchJSON(url, data: data.toJSON())
    }
    
    public func doPatchURLEncoded<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<T>> {
        return self.doPatchURLEncoded(url, data: data.toJSON())
    }
    
    public func doPatchURLEncoded<T: Mappable>(_ url : String, data: Mappable) -> Observable<RxResult<[T]>> {
        return self.doPatchURLEncoded(url, data: data.toJSON())
    }
    
    public func doPatchURLEncoded(_ url : String, data: Mappable)-> Observable<RxResult<String>> {
        return self.doPatchURLEncoded(url, data: data.toJSON())
    }
    
    //MARK: - DELETE
    public func doDelete<T : Mappable>(_ url:String) -> Observable<RxResult<[T]>> {
        return self.doDelete(url, params: nil)
    }
    
    public func doDelete<T : Mappable>(_ url:String) -> Observable<RxResult<T>> {
        return self.doDelete(url, params: nil)
    }
    
    public func doDelete(_ url:String) -> Observable<RxResult<String>> {
        return self.doDelete(url, params : nil)
    }
    
    public func doDelete<T: Mappable>(_ url:String, params: Mappable) -> Observable<RxResult<[T]>> {
        return self.doDelete(url, params: params.toJSON())
    }
    
    public func doDelete<T: Mappable>(_ url:String, params: Mappable) -> Observable<RxResult<T>> {
        return self.doDelete(url, params: params.toJSON())
    }
    
    public func doDelete(_ url: String, params: Mappable) -> Observable<RxResult<String>> {
        return self.doDelete(url, params: params.toJSON())
    }
    
}


