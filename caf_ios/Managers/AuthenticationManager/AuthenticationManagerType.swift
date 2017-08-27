//
//  AuthenticationManagerType.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/20/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import RxSwift

public protocol AuthenticationManagerType {
    func login<T:UserType>(_ request: LoginRequestType) -> Observable<RxResult<T>>
    func register(_ request: RegisterRequestType) -> Observable<RxResult<String>>
    func registerOrLoginExternal<T:UserType>(_ request: SocialAuthenticationRequestType) -> Observable<RxResult<T>>
    func resetPassword(_ request: ResetPasswordRequestType) -> Observable<RxResult<String>>
    func changePassword(_ request: ChangePasswordRequestType) -> Observable<RxResult<String>>
}
