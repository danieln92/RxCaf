//
//  RxKingfisher.swift
//
//  Created by Duy Nguyen on 2/20/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
import Kingfisher

extension Reactive where Base: UIImageView {
    public var imageUrl: AnyObserver<(String, Bool, Int?)> {
        return UIBindingObserver(UIElement: self.base) {imageView, arguments in
            let imageView = (imageView as UIImageView)
            imageView.kf.indicatorType = arguments.1 ? .activity : .none
            if let fadeTime = arguments.2 {
                imageView.kf.setImage(with: URL(string: arguments.0), options: [.transition(.fade(TimeInterval(fadeTime))), .targetCache(ImageCache.default)])
            } else {
                imageView.kf.setImage(with: URL(string: arguments.0), options: [.targetCache(ImageCache.default)])
            }
            }.asObserver()
    }
}
