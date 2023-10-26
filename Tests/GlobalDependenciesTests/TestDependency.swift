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
extension GlobalDependencies: TestService.Dependency {
    #GlobalDependency(type: TestService)
}

/// Dummy component that adopts the dependency (README Adoption #5.1)
@Dependencies(TestService)
class TestComponent {
    /// Initializer with dependencies (README Adoption #5.2)
    init(dependencies: Dependencies = GlobalDependencies.default) {
        self.dependencies = dependencies
    }

    func doTheTest() {
        dependencies.testService.serviceTest()
    }

    func buildChildComponent() -> ChildComponent {
        ChildComponent(dependencies: dependencies.buildGlobal())
    }
}

@Dependencies(TestService, TLAService)
class ChildComponent {
    init(dependencies: Dependencies = GlobalDependencies.default) {
        self.dependencies = dependencies
    }

    func doTheTest() {
        dependencies.tlaService.tlaServiceTest()
    }
}
