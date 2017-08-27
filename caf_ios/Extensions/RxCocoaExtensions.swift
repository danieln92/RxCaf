//
//  RxCocoaUtiils.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/20/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

extension Reactive where Base: UIView {
    public var visible: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self.base) { view, visible in
            view.isHidden = !visible
            }.asObserver()
    }
}

extension Reactive where Base: UIButton {
    public var highlighted: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self.base) { view, highlighted in
            view.isHighlighted = highlighted
            }.asObserver()
    }
    
    /// Reactive wrapper for `TouchUpInside` control event.
    public var singleTap: Observable<Void> {
        return delayableTap(5)
    }
    
    public func delayableTap(_ delayTime: Int) -> Observable<Void> {
        return controlEvent(.touchUpInside).asObservable().throttle(RxTimeInterval(delayTime), latest: false, scheduler: MainScheduler.instance)
    }
}

extension Reactive where Base: UIResponder {
    public var firstResponder: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self.base) {control, shouldRespond in
            _ = shouldRespond ? control.becomeFirstResponder() : control.resignFirstResponder()
            }.asObserver()
    }
}

extension Reactive where Base: UITextField {
    public var placeholder: AnyObserver<String> {
        return UIBindingObserver(UIElement: self.base) {control, placeholder in
            control.placeholder = placeholder
            }.asObserver()
    }
}
