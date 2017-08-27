//
//  ToastService.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/23/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//
import Toaster

open class ToastManager : ToastManagerType {
    
    public init() {}
    
    public func show(_ message: String, duration: Int) {
        let toast = Toast(text: message, duration: TimeInterval(duration))
        toast.show()
    }

    public func show(_ message: String) {
        show(message, duration: 2)
    }
    
    public func hide() {
        if let currentToast = ToastCenter.default.currentToast {
            currentToast.cancel()
        }
    }
}
