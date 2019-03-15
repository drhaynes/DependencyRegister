//
//  ServiceRegistrar.swift
//  DependencyRegister
//
//  Created by David Haynes on 15/03/2019.
//  Copyright © 2019 David Haynes. All rights reserved.
//

import Foundation

final class ServiceProviderRegistrar {
    let registrationKey: String
    private var serviceRegister = [AnyObject]()

    init(registrationKey: String) {
        self.registrationKey = registrationKey
    }

    func add<Service>(serviceCreator: @escaping () -> Service, cacheService: Bool) -> ServiceRegistration<Service> {
        let serviceRegistration = ServiceRegistration(serviceType: Service.self, creator: serviceCreator, cacheService: cacheService)
        serviceRegister.append(serviceRegistration)
        return serviceRegistration
    }

    var last: AnyObject? {
        return serviceRegister.last
    }
}
