//
//  ProgressDialogService.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/21/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import RxSwift
import NVActivityIndicatorView

open class ProgressDialogManager: ProgressDialogManagerType {
    
    public init() {}
    
    public func loading() -> AnyObserver<Bool> {
        return AnyObserver { [unowned self] e in
            MainScheduler.ensureExecutingOnScheduler()
            switch e {
            case .next(let isActive):
                isActive ? self.show() : self.hide()
                break
            case .error, .completed:
                self.hide()
                break
            }
        }
    }
    
    public func show() {
        let activityData = ActivityData(size: nil, message: nil, type: .ballSpinFadeLoader, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    public func hide() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}
