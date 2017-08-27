//
//  BaseSmartTextFieldViewController.swift
//
//  Created by Duy Nguyen on 2/21/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

open class BaseRxSmartTextFieldViewController: BaseRxViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    open var defaultReturnKeyType : UIReturnKeyType {
        return .done
    }

    // MARK: - RxThings
    fileprivate var smartDidEnd : AnyObserver<Void> {
        return AnyObserver { [unowned self]  event in
            switch event {
            case .completed:
                break
            case .next:
                self.view.endEditing(true)
                self.smartAction.onNext(())
                break
            default:
                break
            }
        }
    }
    
    fileprivate var smartBecomeFirstResponder : AnyObserver<UIControl> {
        return AnyObserver { event in
            switch event {
            case .completed:
                break
            case .next(let control):
                control.becomeFirstResponder()
                break
            default:
                break
            }
        }
    }
    
    fileprivate var whenTap : AnyObserver<Void> {
        return AnyObserver { [unowned self]  event in
            switch event {
            case .completed:
                break
            case .next:
                self.view.endEditing(true)
                break
            default:
                break
            }
        }
    }
    
    open var smartAction = PublishSubject<Void>()
    
    //MARK : - Lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()

        setupTextFields(self.view)
        setupButtons(self.view)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    fileprivate func setupTextFields(_ view : UIView) {
        for subview in view.subviews {
            if subview is UITextField {
                (subview as! UITextField).delegate = self
                if let foundTextField = findNextTextField(self.view, subview.tag) {
                    (subview as! UITextField).returnKeyType = .next
                    (subview as! UIControl).rx.controlEvent(.editingDidEndOnExit).replaceWith(foundTextField).bind(to: smartBecomeFirstResponder).addDisposableTo(rx_disposeBag)
                    continue
                } else {
                    (subview as! UITextField).returnKeyType = defaultReturnKeyType
                    (subview as! UIControl).rx.controlEvent(.editingDidEndOnExit).bind(to: smartDidEnd).addDisposableTo(rx_disposeBag)
                    break
                }
            }

            if subview.subviews.count > 0 {
                setupTextFields(subview)
            }
        }
    }
    
    fileprivate func findNextTextField(_ view : UIView, _ tag: Int = 0) -> UIControl? {
        if (view is UITextField) && (view.tag == tag + 1){
            return view as? UIControl
        }
        
        if view.subviews.count > 0 {
            for subview in view.subviews {
                if let foundTextField = findNextTextField(subview, tag) {
                    return foundTextField
                } else {
                    continue
                }
            }
        }
        return nil
    }
    
    fileprivate func setupButtons(_ view : UIView) {
        for subview in view.subviews {
            if subview is UIButton {
                (subview as! UIButton).rx.tap.bind(to: self.whenTap).addDisposableTo(rx_disposeBag)
            }
            
            if subview.subviews.count > 0 {
                setupButtons(subview)
            }
        }
    }

    
    // MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

}
