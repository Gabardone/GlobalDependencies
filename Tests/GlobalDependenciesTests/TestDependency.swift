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
@Dependency()
protocol TestService {
    func serviceTest()
}

/// A Default implementation of `TestService`. Configurable. (README Adoption #2)
class DefaultTestService: TestService {
    var testOverride: (() -> Void)?

    func serviceTest() {
        // Fail the test if we get a call without having set up a block to expect it.
        testOverride?() ?? XCTFail("Unexpected call to `DefaultTestService.test()`")
    }
}

/// Extend GlobalDependencies to implement `TestServiceDependency` (README Adoption #4)
extension GlobalDependencies: TestServiceDependency {
    var testService: any TestService {
        resolveDependencyFor(key: TestServiceDependencyKey.self)
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
@Dependency(lowercased: "tlaService", defaultValueType: TestManagerImpl)
protocol TLAService {
    func managerTest()
}

struct TestManagerImpl: TLAService {
    func managerTest() {
        XCTFail("No tests expected to call this so far")
    }
}

extension GlobalDependencies: TLAServiceDependency {
    var tlaService: any TLAService {
        resolveDependencyFor(key: TLAServiceDependencyKey.self)
    }
}

class ChildComponent {
    private let dependencies: any TLAServiceDependency

    init(dependencies: GlobalDependencies = .default) {
        self.dependencies = dependencies
    }

    func doTheTest() {
        dependencies.tlaService.managerTest()
    }
}
