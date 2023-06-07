//
//  TestDependency.swift
//
//
//  Created by Óscar Morales Vivó on 2/5/23.
//

import Foundation
@testable import GlobalDependencies
import XCTest

/// A Dummy dependency protocol to test out the dependency injection system. (README Adoption #1)
protocol TestService {
    func serviceTest()
}

/// A Default implementation of `TestService`. Configurable. (README Adoption #2)
class DefaultTestService: TestService {
    // Keep it accessible for tests, but be sure to always clean up on the way out of the test.
    static var shared = DefaultTestService()

    var testOverride: (() -> Void)?

    func serviceTest() {
        // Fail the test if we get a call without having set up a block to expect it.
        testOverride?() ?? XCTFail("Unexpected call to `DefaultTestService.test()`")
    }
}

/// The associated dependency protocol for the `TestService` protocol. (README Adoption #3)
protocol TestServiceDependency: Dependencies {
    var testService: any TestService { get }
}

/// Extend GlobalDependencies to implement `TestServiceDependency` (README Adoption #4)
extension GlobalDependencies: TestServiceDependency {
    var testService: any TestService {
        resolveDependency(forKeyPath: \.testService, defaultImplementation: DefaultTestService.shared)
    }
}

/// Dummy component that adopts the dependency (README Adoption #5.1)
class TestComponent {
    private let dependencies: any TestServiceDependency

    /// Initializer with dependencies (README Adoption #5.2)
    init(dependencies: GlobalDependencies = .default) {
        self.dependencies = dependencies
    }

    func doTheTest() {
        dependencies.testService.serviceTest()
    }

    func buildChildComponent() -> ChildComponent {
        ChildComponent(dependencies: dependencies.buildGlobal())
    }
}

/// Another depdendency for child dependency testing.
protocol TestManager {
    func managerTest()
}

struct DefaultTestManager: TestManager {
    func managerTest() {
        XCTFail("No tests expected to call this so far")
    }
}

protocol TestManagerDependency: Dependencies {
    var testManager: any TestManager { get }
}

extension GlobalDependencies: TestManagerDependency {
    var testManager: TestManager {
        resolveDependency(forKeyPath: \.testManager, defaultImplementation: DefaultTestManager())
    }
}

class ChildComponent {
    private let dependencies: any TestManagerDependency

    init(dependencies: GlobalDependencies = .default) {
        self.dependencies = dependencies
    }

    func doTheTest() {
        dependencies.testManager.managerTest()
    }
}
