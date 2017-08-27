//  Created by Duy Nguyen on 2/7/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    func setPresentAnimation() {
        Hero.shared.setDefaultAnimationForNextTransition(HeroDefaultAnimationType.cover(direction: HeroDefaultAnimationType.Direction.up))
    }
    
    func setDismissAnimation() {
        Hero.shared.setDefaultAnimationForNextTransition(HeroDefaultAnimationType.uncover(direction: .down))
    }
}

public extension UIViewController {
    
    // MARK: - Navigation
    public func rxPop(animated: Bool) -> AnyObserver<Void> {
        return AnyObserver<Void>(eventHandler: {[weak self] _ in
            guard let _self = self else { return }
            _ = _self.navigationController?.popViewController(animated: animated)
        })
    }
    
    public func rxPopTo(animated: Bool) -> AnyObserver<UIViewController.Type> {
        return AnyObserver { [weak self] event in
            guard let _self = self else { return }
            switch event {
            case .next(let viewControllerType):
                let foundVC = _self.navigationController?.viewControllers.first(where: { vc -> Bool in
                    vc.isKind(of: viewControllerType)
                })
                
                if let viewController = foundVC {
                    _ = _self.navigationController?.popToViewController(viewController, animated: true)
                }
                break
            default:
                break
            }
        }
    }
    
    func rxPopTo(animated: Bool) -> AnyObserver<[UIViewController.Type]> {
        return AnyObserver { [weak self] event in
            guard let _self = self else { return }
            switch event {
            case .next(let viewControllerTypes):
                for viewControllerType in viewControllerTypes {
                    let foundVC = _self.navigationController?.viewControllers.first(where: { vc -> Bool in
                        vc.isKind(of: viewControllerType)
                    })
                    
                    if let viewController = foundVC {
                        _ = _self.navigationController?.popToViewController(viewController, animated: true)
                        break
                    }
                }
                break
            default:
                break
            }
        }
    }
    
    public func rxPush(animated: Bool) -> AnyObserver<UIViewController?> {
        return AnyObserver { [weak self] event in
            guard let _self = self else { return }
            switch event {
            case .next(let willPresentVC):
                if let willPresentVC = willPresentVC {
                    _self.navigationController?.pushViewController(willPresentVC, animated: true)
                }
                break
            default:
                break
            }
        }
    }
    
    public func rxPresent(animated: Bool , completion: (() -> Void)? ) -> AnyObserver<UIViewController?> {
        return AnyObserver { [weak self] event in
            guard let _self = self else { return }
            switch event {
            case .next(let willPresentVC):
                if let willPresentVC = willPresentVC {
                    _self.setPresentAnimation()
                    _self.navigationController?.pushViewController(willPresentVC, animated: true)
                }
                break
            default:
                break
            }
        }
    }
    
    public func rxDismiss(animated: Bool , completion: (() -> Void)? ) -> AnyObserver<Void> {
        return AnyObserver<Void>(eventHandler: {[weak self] _ in
            guard let _self = self else { return }
            _self.setDismissAnimation()
            _ = _self.navigationController?.popViewController(animated: animated)
        })
    }
    
    // MARK: - Alert
    
    public func showPrompt(title: String, message: String, cancel: String, action: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let _self = self else { return Disposables.create() }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in
                observer.onNext(false)
            }))
            
            alertController.addAction(UIAlertAction(title: action, style: .default, handler: { _ in
                observer.onNext(true)
            }))
            
            _self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    public func showAlert(title: String, message: String, cancel: String, actions : (String, UIAlertActionStyle)...) -> Observable<(Int,String)> {
        return Observable.create { [weak self] observer in
            guard let _self = self else { return Disposables.create() }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: cancel, style: .cancel , handler: {_ in
                observer.onNext((0, cancel))
            }))
            
            for i in 0..<actions.count {
                let action = actions[i]
                if action.0.isEmpty {
                    continue
                }
                alertController.addAction(UIAlertAction(title: action.0, style: action.1, handler: { _ in
                    observer.onNext((i + 1, action.0))
                }))
            }
            
            _self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public func showActionSheet(title: String, message: String, cancel: String, actions : (String, UIAlertActionStyle)...) -> Observable<(Int,String)> {
        return Observable.create { [weak self] observer in
            guard let _self = self else { return Disposables.create() }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: cancel, style: .cancel, handler: {_ in
                observer.onNext((0, cancel))
            }))
            
            for i in 0..<actions.count {
                let action = actions[i]
                if action.0.isEmpty {
                    continue
                }
                alertController.addAction(UIAlertAction(title: action.0, style: action.1, handler: { _ in
                    observer.onNext((i + 1, action.0))
                }))
            }
            
            _self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}
