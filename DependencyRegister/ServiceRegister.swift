//
//  ServiceRegister.swift
//  DependencyRegister
//
//  Created by David Haynes on 15/03/2019.
//  Copyright © 2019 David Haynes. All rights reserved.
//

import Foundation

/// Represents registration of an individual service.
public final class ServiceRegistration<Service> {
    let serviceType: Service.Type
    private let creationPolicy: ServiceCreationPolicy<Service>

    init(serviceType: Service.Type, creator: @escaping () -> Service, cacheService: Bool) {
        self.serviceType = serviceType
        if cacheService {
            creationPolicy = .cached(service: creator())
        } else {
            creationPolicy = .uncached(creator: creator)
        }
    }

    var service: Service {
        switch creationPolicy {
        case let .cached(service):
            return service
        case let .uncached(creator):
            return creator()
        }
    }
}

private enum ServiceCreationPolicy<Service> {
    /// The service will be cached, essentially treating it as a (replaceable) single instance.
    case cached(service: Service)
    /// The service will be uncached, allowing for e.g. factory-style injection at the point of use.
    case uncached(creator: () -> Service)
}

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
