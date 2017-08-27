//
//  CollectionView+.swift
//  RxCaf
//
//  Created by Duy Nguyen on 7/14/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit

public extension UICollectionView {
    public func dequeueCell<T>(ofType type: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }
    
    public func registerNibs(_ cellReuseIdentifiers: String... ) {
        for cellReuseIdentifier in cellReuseIdentifiers {
            self.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        }
    }
}

#endif
