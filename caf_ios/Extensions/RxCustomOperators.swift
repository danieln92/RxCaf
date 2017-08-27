//
//  RxCustomOperators.swift
//
//  Created by Duy Nguyen on 2/20/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

public extension ObservableType {
    func replaceWith<R>(_ value : R) -> Observable<R> {
        return map{ _ in value }
    }
}
