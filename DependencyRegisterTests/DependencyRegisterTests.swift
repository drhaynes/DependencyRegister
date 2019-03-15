//
//  DependencyRegisterTests.swift
//  DependencyRegisterTests
//
//  Created by David Haynes on 15/03/2019.
//  Copyright © 2019 David Haynes. All rights reserved.
//

import XCTest
import Nimble
@testable import DependencyRegister

class DependencyRegisterTests: XCTestCase {
    var container: DependencyContainer!

    override func setUp() {
        super.setUp()
        container = DependencyContainer()
    }
    override func tearDown() {
        container = nil
        super.tearDown()
    }

    func testOnlyASingleInstanceIsEverCreated() {
        let firstContainer = DependencyContainer.shared
        let secondContainer = DependencyContainer.shared
        expect(firstContainer).to(beIdenticalTo(secondContainer))
    }

    func testRegistrationAndResolutionOfASingleService() {
        let service = TestService()
        container.register(service: TestServiceProtocol.self) {
            return service
        }
        container.resolve(TestServiceProtocol.self).testFunction()
        expect(service.functionWasCalled).to(beTruthy())
    }

    func testAutoclosureRegistrationOfSingleService() {
        container.register(TestService(), for: TestServiceProtocol.self)
        let service = container.resolve(TestServiceProtocol.self)
        service.testFunction()
        expect(service.functionWasCalled).to(beTruthy())
    }

    func testItIsPossibleToResolveADependencyUsingTheResolveFunction() {
        let service = TestService()
        DependencyContainer.shared.register(service: TestServiceProtocol.self) {
            return service
        }
        resolve(TestServiceProtocol.self).testFunction()
        expect(service.functionWasCalled).to(beTruthy())
    }

    func testResolvingAnUnregisteredServiceCausesAnError() {
        expect {
            let _ = resolve(UITableViewDelegate.self)
            return nil
            }.to(throwAssertion())
    }

    func testMultipleRegistrationResolvesLastRegisteredService() {
        let originalService = TestService()
        let secondService = AnotherTestService()
        container.register(originalService, for: TestServiceProtocol.self)
        container.register(secondService, for: TestServiceProtocol.self)

        let resolvedService = container.resolve(TestServiceProtocol.self)
        expect(resolvedService).toNot(beIdenticalTo(originalService))
        expect(resolvedService).to(beIdenticalTo(secondService))
    }

    func testOptionalResolvingForRegisteredService() {
        let service = TestService()
        container.register(service, for: TestServiceProtocol.self)
        let resolved = container.resolveOptional(TestServiceProtocol.self)
        expect(resolved).toNot(beNil())
    }

    func testOptionalResolvingWithNoRegisteredService() {
        let resolved = container.resolveOptional(TestServiceProtocol.self)
        expect(resolved).to(beNil())
    }

}

// MARK: Service caching tests
extension DependencyRegisterTests {
    func testANewServiceIsCreatedEveryTimeWithCachingDisabled() {
        container.register(service: TestServiceProtocol.self, cacheService: false) {
            TestService()
        }

        let firstService = container.resolve(TestServiceProtocol.self)
        let secondService = container.resolve(TestServiceProtocol.self)
        expect(firstService).notTo(beIdenticalTo(secondService))
    }

    func testAnIdenticalServiceIsProvidedEveryTimeWithCachingEnabled() {
        container.register(service: TestServiceProtocol.self, cacheService: true) {
            TestService()
        }

        let firstService = container.resolve(TestServiceProtocol.self)
        let secondService = container.resolve(TestServiceProtocol.self)
        expect(firstService).to(beIdenticalTo(secondService))
    }
}

// MARK: Test mocks

protocol TestServiceProtocol {
    var functionWasCalled: Bool { get }
    func testFunction()
}

class TestService: TestServiceProtocol {
    var functionWasCalled = false
    func testFunction() {
        functionWasCalled = true
    }
}

class AnotherTestService: TestServiceProtocol {
    var functionWasCalled = false
    func testFunction() {
        functionWasCalled = true
    }
}
