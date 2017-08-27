//
//  TextValidatorService.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/23/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import Validator

open class TextValidationManager : TextValidationManagerType {
    
    public init() {}
    
    public func validateEmail(_ email: String) -> Observable<Bool> {
        return Observable.create { observer in
            if email.isEmpty  {
                observer.onNext(false)
                return Disposables.create()
            }
            
            let result = email.validate(rule: ValidationRulePattern(pattern: EmailValidationPattern.standard, error: NSError()))
            
            switch result {
            case .valid:
                observer.onNext(true)
                break
            case .invalid:
                observer.onNext(false)
                break
            }
            return Disposables.create()
        }
    }
    
    public func validateByRange(_ str: String, minLength : Int, maxLength : Int) -> Observable<Bool> {
        return Observable.create { observer in
            if str.isEmpty  {
                observer.onNext(false)
                return Disposables.create()
            }
            
            let result = str.validate(rule: ValidationRuleLength(min: minLength, max: maxLength, error: NSError()))
            
            switch result {
            case .valid:
                observer.onNext(true)
                break
            case .invalid:
                observer.onNext(false)
                break
            }
            return Disposables.create()
        }
    }
    
    public func validateNumber(_ number : String, minValue : Double, maxValue : Double) -> Observable<Bool> {
        return Observable.create { observer in
            if number.isEmpty  {
                observer.onNext(false)
                return Disposables.create()
            }
            
            let numericRule = ValidationRuleComparison<Double>(min: minValue, max: maxValue, error: NSError())
            if let result = Double(number)?.validate(rule : numericRule) {
                switch result {
                case .valid:
                    observer.onNext(true)
                    break
                case .invalid:
                    observer.onNext(false)
                    break
                }
            } else {
                observer.onNext(false)
            }
            return Disposables.create()
        }
    }
}
