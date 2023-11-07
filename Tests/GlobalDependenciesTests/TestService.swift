//
//  TestService.swift
//
//
//  Created by Óscar Morales Vivó on 11/5/23.
//

import Foundation
import GlobalDependencies
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

private struct DefaultTestServiceValueFactory: DefaultDependencyValueFactory {
    static func makeDefaultValue() -> DefaultTestService {
        DefaultTestService()
    }
}

/// Extend GlobalDependencies to implement `TestServiceDependency` (README Adoption #4)
extension GlobalDependencies: TestService.Dependency {
    #GlobalDependency(type: TestService)
}
