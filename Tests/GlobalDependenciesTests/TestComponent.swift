//
//  TestComponent.swift
//
//
//  Created by Óscar Morales Vivó on 2/5/23.
//

import Foundation
@testable import GlobalDependencies
import XCTest

/// Dummy component that adopts the dependency (README Adoption #5.1)
@InjectedDependencies(TestService)
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

@InjectedDependencies(TestService, TLAService)
class ChildComponent {
    init(dependencies: Dependencies = GlobalDependencies.default) {
        self.dependencies = dependencies
    }

    func doTheTest() {
        dependencies.tlaService.tlaServiceTest()
    }
}
