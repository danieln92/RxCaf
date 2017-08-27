//
//  PProgressDialogService.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/21/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import RxSwift

public protocol ProgressDialogManagerType {
    func loading() -> AnyObserver<Bool>
    func show()
    func hide()
}

