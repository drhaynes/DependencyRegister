//
//  ServiceRegister.swift
//  DependencyRegister
//
//  Created by David Haynes on 15/03/2019.
//  Copyright © 2019 David Haynes. All rights reserved.
//

import Foundation

/// Service creation policies
///
/// - cached: Always use the cached service instance.
/// - uncached: Always create a new service instance when this service is requested.
private enum ServiceCreationPolicy<Service> {
    /// The service will be cached, essentially treating it as a (replaceable) single instance.
    case cached(service: Service)
    /// The service will be uncached, allowing for e.g. factory-style injection at the point of use.
    case uncached(creator: () -> Service)
}

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
