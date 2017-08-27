//
//  SocialLoginRequestType.swift
//  RxCaf
//
//  Created by Duy Nguyen on 3/20/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import ObjectMapper

public enum SocialMediaPlatform : String {
    case facebook = "facebook"
    case twitter = "twitter"
    case google = "google"
    case linkedin = "linkedin"
}

public protocol SocialAuthenticationRequestType : Mappable {
    var provider: String? {get}
    var externalAccessToken: String? {get}
}
