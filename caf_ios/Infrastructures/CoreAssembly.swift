//
//  CoreAssembler.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/22/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Swinject

class CoreAssembly : Assembly {
    func assemble(container: Container) {
        container.register(ProgressDialogManagerType.self) { r in
            ProgressDialogManager()
        }.inObjectScope(.container)
        
        container.register(ToastManagerType.self) { r in
            ToastManager()
            }.inObjectScope(.container)
        
        container.register(TextValidationManagerType.self) { r in
            TextValidationManager()
            }.inObjectScope(.container)

    }
}
