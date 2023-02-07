//
//  MiniDePinTests.swift
//
//
//  Created by Óscar Morales Vivó on 2/5/23.
//

@testable import MiniDePin
import XCTest

final class MiniDePinTests: XCTestCase {
    override func setUp() {
        // Replace the "singleton" one in case the prior test messed with it.
        DefaultTestService.shared = DefaultTestService()
    }

    func testDefaultDependency() throws {
        let defaultExpectation = expectation(description: "DefaultTestService.shared.test() called")
        DefaultTestService.shared.testOverride = {
            defaultExpectation.fulfill()
        }

        let testComponent = TestComponent()
        testComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }

    func testOverwrittenDependency() throws {
        struct MockService: TestService {
            func serviceTest() {
                expectation.fulfill()
            }

            let expectation: XCTestExpectation
        }

        let mockExpectation = expectation(description: "Mock expectation's `test()` called")
        let mockService = MockService(expectation: mockExpectation)

        let testComponent = TestComponent(dependencies: .default.with(override: mockService, for: \.testService))
        testComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }

    func testOverwrittenIndirectDependency() throws {
        struct MockService: TestManager {
            func managerTest() {
                expectation.fulfill()
            }

            let expectation: XCTestExpectation
        }

        let mockExpectation = expectation(description: "Mock expectation's `test()` called")
        let mockService = MockService(expectation: mockExpectation)

        let testComponent = TestComponent(dependencies: .default.with(override: mockService, for: \.testManager))
        let childComponent = testComponent.buildChildComponent()

        childComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }
}
