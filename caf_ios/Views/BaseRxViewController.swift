//
//  BaseViewController.swift
//
//  Created by Duy Nguyen on 2/14/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol RxViewControllerType {
    associatedtype ViewModelType
    var viewModel : ViewModelType? {get set}
}

open class BaseRxViewController: UIViewController  {

    override open func viewDidLoad() {
        super.viewDidLoad()
        #if TRACE_RESOURCES
            print("Number of start resources = \(RxSwift.Resources.total)")
        #endif        
        
        self.automaticallyAdjustsScrollViewInsets = false
    }

    deinit {
        #if TRACE_RESOURCES
            print("\(self) disposed with \(RxSwift.Resources.total) resources")
        #endif
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

}

