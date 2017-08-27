//
//  PService.swift
//  AVB
//
//  Created by Duy Nguyen on 3/2/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import RxSwift
import RxSwiftUtilities

protocol RxManagerType {
    var progressDialogManager : ProgressDialogManagerType {get set}
}

open class BaseRxManager : RxManagerType {
    
    var progressDialogManager: ProgressDialogManagerType
    
    let disposeBag = DisposeBag()
    
    public let indicator = ActivityIndicator()
    
    public init(progressDialogManager: ProgressDialogManagerType) {
        self.progressDialogManager = progressDialogManager
        
        indicator.asObservable().bind(to: self.progressDialogManager.loading()).addDisposableTo(disposeBag)
    }
}

