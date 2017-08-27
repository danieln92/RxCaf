//
//  UserType.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/17/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import ObjectMapper

public protocol UserType : Mappable {
    var id : String? { get }
    var username : String? { get }
    var accessToken : String? { get }
    var email : String? { get }
}

