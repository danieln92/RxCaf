//
//  PTextValidatorService.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/23/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import RxSwift

public protocol TextValidationManagerType {
    func validateEmail(_ email: String) -> Observable<Bool>
    func validateByRange(_ str: String, minLength : Int, maxLength : Int) -> Observable<Bool>
    func validateNumber(_ number : String, minValue : Double, maxValue : Double) -> Observable<Bool>
}

