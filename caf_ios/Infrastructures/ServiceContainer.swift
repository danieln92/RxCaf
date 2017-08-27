//
//  ServiceManager.swift
//  RxCaf
//
//  Created by Duy Nguyen on 2/23/17.
//  Copyright © 2017 Duy Nguyen. All rights reserved.
//

import Swinject

public protocol ServiceContainerType {
    func registerService(_ assembly: Assembly)
    func registerServices(_ assemblies: [Assembly])
    func getResolver() -> Resolver
}

open class ServiceContainer : ServiceContainerType {
    public static let sharedInstance = ServiceContainer()
    private init() {}
    
    private var _assembler : Assembler?
    private var assembler : Assembler {
        if _assembler == nil {
            _assembler = Assembler([CoreAssembly()])
        }
        return _assembler!
    }
    
    public func getResolver() -> Resolver {
        return assembler.resolver
    }
    
    public func registerService(_ assembly: Assembly) {
        assembler.apply(assembly: assembly)
    }
    
    public func registerServices(_ assemblies: [Assembly]) {
        assembler.apply(assemblies: assemblies)
    }
}
