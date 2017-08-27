//
//  PRxRestService.swift
//  CAF_iOS
//
//  Created by Duy Nguyen on 2/27/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation
import RxAlamofire
import Alamofire
import ObjectMapper
import AlamofireActivityLogger
#if !RX_NO_MODULE
    import RxSwift
#endif

public enum RxResult<T> {
    case success(T)
    case successWithPaging(T, PaginationType)
    case failure(Error)
}

public struct CAFMultipartFormData {
    public var data : Data
    public var fileName : String
    public var mimeType : String
    
    public init(data: Data, fileName: String, mimeType: String) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}


public protocol RxRestManagerType {
    var baseURL : String {get}
    var token : String {get}
    var headers : [String:String]? {get}
    var messageType : CAFMessageType {get}
    
    func appendSegments(_ urlSegments : String...) -> String
    func error(code: Int, message : String) -> NSError
    func error(code: Int) -> NSError
    
    func doGet<T : Mappable>(_ url: String, params: [String:Any]?) -> Observable<RxResult<[T]>>
    func doGet<T : Mappable>(_ url: String, params: [String:Any]?) -> Observable<RxResult<T>>
    func doGet(_ url: String , params: [String:Any]?) -> Observable<RxResult<String>>
    
    func doPostJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>>
    func doPostJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>>
    func doPostJSON(_ url : String, data : [String : Any]?)-> Observable<RxResult<String>>
    func doPostURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>>
    func doPostURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>>
    func doPostURLEncoded(_ url : String, data : [String : Any]?) -> Observable<RxResult<String>>
    
    func doPutJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>>
    func doPutJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>>
    func doPutJSON(_ url : String, data : [String : Any]?)-> Observable<RxResult<String>>
    func doPutURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>>
    func doPutURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>>
    func doPutURLEncoded(_ url : String, data : [String : Any]?) -> Observable<RxResult<String>>
    
    func doPatchJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>>
    func doPatchJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>>
    func doPatchJSON(_ url : String, data : [String : Any]?)-> Observable<RxResult<String>>
    func doPatchURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>>
    func doPatchURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>>
    func doPatchURLEncoded(_ url : String, data : [String : Any]?) -> Observable<RxResult<String>>
    
    func doDelete<T : Mappable>(_ url: String, params : [String:Any]?) -> Observable<RxResult<[T]>>
    func doDelete<T : Mappable>(_ url: String, params : [String:Any]?) -> Observable<RxResult<T>>
    func doDelete(_ url: String , params : [String:Any]?) -> Observable<RxResult<String>>
    
    func doPostMultipartFormDataJSON(_ url: String, datas : [String:CAFMultipartFormData]?, params : [String:Any]?) -> Observable<RxResult<String>>
}

public extension RxRestManagerType {
    public func appendSegments(_ urlSegments : String...) -> String {
        var url = self.baseURL
        for urlSegment in urlSegments {
            if urlSegment.isEmpty {
                continue
            }
            let newUrlSegment = urlSegment.characters.last! == "/" ? urlSegment.substring(to: urlSegment.index(urlSegment.endIndex, offsetBy: -1)) : urlSegment
            url += "/" + newUrlSegment
        }
        return url.characters.first == "/" ? url.substring(from: url.index(url.startIndex, offsetBy: 1)) : url
    }
    
    public func error(code: Int, message : String) -> NSError {
        return NSError(domain: "\(self)", code: code, userInfo: [NSLocalizedDescriptionKey : message])
    }
    
    public func error(code: Int) -> NSError {
        if let message = self.messageType.messageLibrary[code] {
            return self.error(code: code, message: message)
        }
        return NSError(domain: "\(self)", code: code, userInfo: [NSLocalizedDescriptionKey : "Not found errorMessage for errorCode \(code)"])
    }
    
    public func doGet<T : Mappable>(_ url: String, params: [String:Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    if let paging = apiResponse.paging {
                                        observer.onNext(.successWithPaging(datas,paging))
                                    } else {
                                        observer.onNext(.success(datas))
                                    }
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                                
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doGet<T : Mappable>(_ url: String, params: [String:Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                                
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doGet(_ url:String , params : [String:Any]?) -> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPostJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .post, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                                
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPostJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .post, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    observer.onNext(.success(datas))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                                
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPostJSON(_ url : String, data : [String : Any]?)-> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .post, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPostURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .post, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPostURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .post, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    observer.onNext(.success(datas))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPostURLEncoded(_ url : String, data : [String : Any]?) -> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .post, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPutJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .put, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPutJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .put, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    observer.onNext(.success(datas))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPutJSON(_ url : String, data : [String : Any]?)-> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .put, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPutURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .put, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPutURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .put, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    observer.onNext(.success(datas))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                                
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPutURLEncoded(_ url : String, data : [String : Any]?) -> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .put, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPatchJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .patch, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPatchJSON<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .patch, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    observer.onNext(.success(datas))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPatchJSON(_ url : String, data : [String : Any]?)-> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .patch, parameters: data, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPatchURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .patch, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPatchURLEncoded<T : Mappable>(_ url : String, data : [String : Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .patch, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    observer.onNext(.success(datas))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                                
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPatchURLEncoded(_ url : String, data : [String : Any]?) -> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .patch, parameters: data, encoding: URLEncoding.httpBody, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    
    public func doDelete<T : Mappable>(_ url: String, params : [String:Any]?) -> Observable<RxResult<[T]>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .delete, parameters: params, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let datas = apiResponse.datas {
                                    observer.onNext(.success(datas))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doDelete<T : Mappable>(_ url: String, params : [String:Any]?) -> Observable<RxResult<T>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .delete, parameters: params, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<APIResponse<T>>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let data = apiResponse.data {
                                    observer.onNext(.success(data))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doDelete(_ url: String , params : [String:Any]?) -> Observable<RxResult<String>> {
        return Observable.create { observer in
            Alamofire.request( url , method: .delete, parameters: params, encoding: JSONEncoding.default, headers : self.headers).log(level: .all, options: [.onlyDebug, .jsonPrettyPrint, .includeSeparator])
                .responseJSON { (response) in
                    if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                            if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                let customError = self.error(code: errorCode)
                                observer.onNext(.failure(customError))
                            }
                        } else {
                            observer.onNext(.failure(self.error(code: statusCode, message: message)))
                        }
                        observer.onCompleted()
                    }
                    if let statusCode = response.response?.statusCode,statusCode == 401 {
                        observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                        observer.onCompleted()
                    }
                    switch response.result {
                    case .failure(let error) :
                        observer.onNext(.failure(error))
                    case .success(let responseObject) :
                        if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                            if apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                if let dataAsString = apiResponse.dataAsString {
                                    observer.onNext(.success(dataAsString))
                                } else {
                                    let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                    observer.onNext(.failure(customError))
                                }
                            }
                        }
                    }
                    observer.onCompleted()
            }
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    public func doPostMultipartFormDataJSON(_ url: String, datas : [String:CAFMultipartFormData]?, params : [String:Any]?) -> Observable<RxResult<String>> {
        return Observable.create { observer in
            var urlRequest = try! URLRequest(url: url, method: .post, headers: self.headers)
            //set http body
            if let params = params {
                do {
                    let data = try JSONSerialization.data(withJSONObject: params, options: [])
                    urlRequest.httpBody = data
                } catch {
                    observer.onNext(.failure(AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))))
                    observer.onCompleted()
                }
            }
            
            Alamofire.upload(multipartFormData: { (formData) in
                if let datas = datas {
                    for (key, value) in datas {
                        formData.append(value.data, withName: key, fileName: value.fileName, mimeType: value.mimeType)
                    }
                }
                
            }, with: urlRequest,
               encodingCompletion: { (response) in
                switch response {
                case .failure(let error):
                    observer.onNext(.failure(error))
                case .success(let uploadRequest, _, _):
                    uploadRequest.responseJSON(completionHandler: { (response) in
                        if let statusCode = response.response?.statusCode, let message = response.response?.description, statusCode >= 500 {
                            if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: response.value), apiResponse.isError() {
                                if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                    let customError = self.error(code: errorCode)
                                    observer.onNext(.failure(customError))
                                }
                            } else {
                                observer.onNext(.failure(self.error(code: statusCode, message: message)))
                            }
                            observer.onCompleted()
                        }
                        if let statusCode = response.response?.statusCode,statusCode == 401 {
                            observer.onNext(.failure(self.error(code: statusCode, message: self.messageType.unauthorizedMessage)))
                            observer.onCompleted()
                        }
                        switch response.result {
                        case .failure(let error) :
                            observer.onNext(.failure(error))
                            observer.onCompleted()
                        case .success(let responseObject) :
                            if let apiResponse = Mapper<BaseAPIResponse>().map(JSONObject: responseObject) {
                                if apiResponse.isError() {
                                    if let errorModel = (apiResponse.errors?[0]), let errorCode = errorModel.errorCode {
                                        let customError = self.error(code: errorCode)
                                        observer.onNext(.failure(customError))
                                    }
                                } else {
                                    if let dataAsString = apiResponse.dataAsString {
                                        observer.onNext(.success(dataAsString))
                                    } else {
                                        let customError = self.error(code: self.messageType.objectMappingFailedCode, message: self.messageType.objectMappingFailedMessage)
                                        observer.onNext(.failure(customError))
                                    }
                                }
                            }
                        }
                        observer.onCompleted()
                    })
                }
            })
            
            return Disposables.create()
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

