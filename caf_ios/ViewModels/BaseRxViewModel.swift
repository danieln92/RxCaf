//
//  BaseViewModel.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/20/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import RxSwift

public extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

public protocol RxViewModelType {
    // MARK: - Life Cycle
    var onViewWillAppear : AnyObserver<Bool> { get }
    var onViewDidAppear : AnyObserver<Bool> { get }
    var onViewWillDisappear : AnyObserver<Bool> { get }
    var onViewDidDisappear : AnyObserver<Bool> { get }
}

public extension RxViewModelType {
    // MARK: - Life Cycle
    var onViewWillAppear : AnyObserver<Bool> {
        return AnyObserver(eventHandler: { _ in
        })
    }
    
    var onViewDidAppear : AnyObserver<Bool> {
        return AnyObserver(eventHandler: { _ in
        })
    }
    
    var onViewWillDisappear : AnyObserver<Bool> {
        return AnyObserver(eventHandler: { _ in
        })
    }
    
    var onViewDidDisappear : AnyObserver<Bool> {
        return AnyObserver(eventHandler: { _ in
        })
    }
}

open class RxBaseViewModel {
    public let serviceContainer = ServiceContainer.sharedInstance
    
    private var showToast = PublishSubject<String>()
    private var unauthorized = PublishSubject<Void>()
    
    public var disposeBag : DisposeBag! = DisposeBag()
    
    deinit {
        #if DEBUG
            print("\(self) VM DEINIT")
        #endif
        disposeBag = nil
    }
    
    public init() {
        showToast.subscribeOn(MainScheduler.instance)
            .subscribe(onNext : { [unowned self] message in
                self.serviceContainer.getResolver().resolve(ToastManagerType.self)?.show(message)
            }).addDisposableTo(disposeBag)
        unauthorized.subscribeOn(MainScheduler.instance)
            .subscribe((UIApplication.shared.delegate as! CAFAppDelegate).handleUnauthorized()).addDisposableTo(disposeBag)
    }
    
    public func showToast(_ message : String) {
        self.showToast.onNext(message)
    }
    
    public func flatMapRxResult<T>(_ observable : Observable<RxResult<T>>) -> Observable<T> {
        return observable.observeOn(MainScheduler.instance)
            .flatMapLatest { result -> Observable<T> in
                switch result {
                case .success(let data) :
                    return Observable.just(data)
                case .successWithPaging(let data, _):
                    return Observable.just(data)
                case .failure(let e):
                    if e.code == 401 {
                        self.unauthorized.onNext(())
                    }
                    self.showToast.onNext(e.localizedDescription)
                }
                return Observable.never()
        }
    }
    
    public func flatMapRxResult<T>(_ observable : Observable<RxResult<T>>, errorHandler: @escaping ((_ error:Error) -> ()) ) -> Observable<T> {
        return observable.observeOn(MainScheduler.instance)
            .flatMapLatest { result -> Observable<T> in
                switch result {
                case .success(let data) :
                    return Observable.just(data)
                case .successWithPaging(let data, _):
                    return Observable.just(data)
                case .failure(let e):
                    if e.code == 401 {
                        self.unauthorized.onNext(())
                    } else {
                        errorHandler(e)
                    }
                }
                return Observable.never()
        }
    }
    
    public func flatMapRxResultWithPaging<T>(_ observable : Observable<RxResult<T>>) -> Observable<(T,PaginationType)> {
        return observable.observeOn(MainScheduler.instance)
            .flatMapLatest { result -> Observable<(T,PaginationType)> in
                switch result {
                case .successWithPaging(let data, let paging) :
                    return Observable.just((data,paging))
                case .failure(let e):
                    self.showToast.onNext(e.localizedDescription)
                default:
                    break
                }
                return Observable.never()
        }
    }
    
}
