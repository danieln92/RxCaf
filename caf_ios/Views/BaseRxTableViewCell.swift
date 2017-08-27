//
//  BaseRxTableViewCell.swift
//  RxCaf
//
//  Created by Duy Nguyen on 4/27/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import UIKit
import RxSwift

open class BaseRxTableViewCell: UITableViewCell {

    private(set) open var disposeBag = DisposeBag()
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag() // because life cicle of every cell ends on prepare for reuse
    }

}
