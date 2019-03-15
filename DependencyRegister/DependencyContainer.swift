//
//  DependencyContainer.swift
//  DependencyRegister
//
//  Created by David Haynes on 15/03/2019.
//  Copyright © 2019 David Haynes. All rights reserved.
//

import Foundation

/// Container used to register and resolve injectable dependencies.
public final class DependencyContainer {
    private var serviceProviderRegistrars = [ServiceProviderRegistrar]()

    /// Returns the dependency container for the application.
    public static let shared = DependencyContainer()

    /// Register a service.
    ///
    /// - Parameters:
    ///   - service: The type of service to register.
    ///   - cacheService: Whether the service instance should be cached or not. Defaults to `true`.
    ///   - creator: Closure that specifies the service creation and returns the service instance.
    /// - Returns: The `ServiceRegistration` entry created during registration.
    @discardableResult
    public func register<Service>(service: Service.Type, cacheService: Bool = true, creator: @escaping () -> Service) -> ServiceRegistration<Service> {
        return registrar(for: service).add(serviceCreator: creator, cacheService: cacheService)
    }

    /// Register a service (autoclosure version). Useful when you're creating a single service instance and caching it.
    ///
    /// - Parameters:
    ///   - instance: Autoclosing block that instantiates the service (usually a constructor call).
    ///   - service: The service type to register.
    /// - Returns: The `ServiceRegistration` entry created during registration.
    @discardableResult
    public func register<Service>(_ instance: @autoclosure @escaping () -> Service, for service: Service.Type) -> ServiceRegistration<Service> {
        return register(service: service, creator: instance)
    }

    /// Resolve a service.
    ///
    /// - Parameter serviceType: The service type you wish to retrieve the service for.
    /// - Returns: A service instance of the requested type. Requesting a service for an unregistered type will cause a fatal error.
    public func resolve<Service>(_ serviceType: Service.Type) -> Service {
        guard let service = resolveOptional(serviceType) else {
            fatalError("No service for: \(String(describing: Service.self))")
        }

        return service
    }

    /// Resolve an optional service.
    ///
    /// - Parameter serviceType: The service type you wish to retrieve the service for.
    /// - Returns: A service instance of the requested type, or nil if one has not been registered.
    public func resolveOptional<Service>(_ serviceType: Service.Type) -> Service? {
        guard let registration = registrar(for: serviceType).last,
            let serviceRegistration = registration as? ServiceRegistration<Service> else {
                return nil
        }
        return serviceRegistration.service
    }

    private func registrar<Service>(for type: Service.Type) -> ServiceProviderRegistrar {
        let registrationKey = String(describing: type)
        if let existingRegistrar = serviceProviderRegistrars.first(where: { $0.registrationKey == registrationKey}) {
            return existingRegistrar
        }
        let serviceProviderRegistrar = ServiceProviderRegistrar(registrationKey: registrationKey)
        serviceProviderRegistrars.append(serviceProviderRegistrar)
        return serviceProviderRegistrar
    }
}

/// Resolve a service for the given service type. Shorthand for `DependencyContainer.shared.resolve(...)`
///
/// - Parameter serviceType: The service type you wish to retrieve an instance of.
/// - Returns: A service instance for the given type. Requesting a service for an unregistered type will cause a fatal error.
public func resolve<Service>(_ serviceType: Service.Type) -> Service {
    return DependencyContainer.shared.resolve(serviceType)
}

/// Resolve an optional service for the given service type. Shorthand for `DependencyContainer.shared.resolveOptional(...)`
///
/// - Parameter serviceType: The service type you wish to retrieve an instance of.
/// - Returns: A service instance of the requested type, or nil if one has not been registered.
public func resolveOptional<Service>(_ serviceType: Service.Type) -> Service? {
    return DependencyContainer.shared.resolveOptional(serviceType)
}
