//
//  DNCoreSetup.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/23/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import RxSwift

public protocol CAFCoreSetup {
    var serviceManager : ServiceContainerType { get }
    var rootViewControllerType: [UIViewController.Type] {get}
    
    func setupLogger()
    func handleUnauthorized() -> AnyObserver<Void>
    func registerRootViewController(_ viewController : UIViewController)
}

open class CAFAppDelegate : UIResponder, UIApplicationDelegate, CAFCoreSetup {
    open func handleUnauthorized() -> AnyObserver<Void> {
        return AnyObserver { [unowned self] event in
            switch event {
            case .next:
                for vcType in self.rootViewControllerType {
                    let foundVC = self.navigationController?.viewControllers.first(where: { vc -> Bool in
                        vc.isKind(of: vcType)
                    })
                    
                    if let viewController = foundVC {
                        _ = self.navigationController?.popToViewController(viewController, animated: true)
                        break
                    } else {
                        print("Trying to handleUnauthorized but no succeed : Not found rootViewControllerType \(vcType)")
                    }
                }
                break
            default:
                break
            }
        }
    }
    
    open var serviceManager: ServiceContainerType {
        return ServiceContainer.sharedInstance
    }
    
    open var rootViewControllerType: [UIViewController.Type] {
        return [UIViewController.self]
    }
    
    open func setupLogger() {}
    
    open var window: UIWindow?
    open var navigationController : UINavigationController?
    
    open func registerRootViewController(_ viewController : UIViewController) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController?.isNavigationBarHidden = true
        navigationController?.isHeroEnabled = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupLogger()
        return true
    }
}
