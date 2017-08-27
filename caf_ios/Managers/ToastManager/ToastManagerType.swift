//
//  PToastService.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/23/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

public protocol ToastManagerType {
    func show(_ message: String)
    func show(_ message: String, duration : Int)
    func hide()
}
