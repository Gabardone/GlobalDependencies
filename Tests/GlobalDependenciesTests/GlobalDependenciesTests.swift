//
//  GlobalDependenciesTests.swift
//
//
//  Created by Óscar Morales Vivó on 2/5/23.
//

@testable import GlobalDependencies
import XCTest

final class GlobalDependenciesTests: XCTestCase {
    func testOverwrittenDependency() throws {
        struct MockService: TestService {
            func serviceTest() {
                expectation.fulfill()
            }

            let expectation: XCTestExpectation
        }

        let mockExpectation = expectation(description: "Mock expectation's `test()` called")
        let mockService = MockService(expectation: mockExpectation)

        let testComponent = TestComponent(
            dependencies: .default.with(override: mockService, for: TestServiceDependencyKey.self)
        )
        testComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }

    func testOverwrittenIndirectDependency() throws {
        struct MockService: TLAService {
            func managerTest() {
                expectation.fulfill()
            }

            let expectation: XCTestExpectation
        }

        let mockExpectation = expectation(description: "Mock expectation's `test()` called")
        let mockService = MockService(expectation: mockExpectation)

        let testComponent = TestComponent(
            dependencies: .default.with(override: mockService, for: TLAServiceDependencyKey.self)
        )
        let childComponent = testComponent.buildChildComponent()

        childComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }
}
