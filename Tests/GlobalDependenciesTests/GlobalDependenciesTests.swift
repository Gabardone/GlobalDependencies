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
            dependencies: GlobalDependencies.default.with(override: mockService, for: TestServiceDependencyKey.self)
        )
        testComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }

    func testResetDependencyToDefault() throws {
        struct MockService: TestService {
            func serviceTest() {
                // We're not expected to call this one here.
                XCTFail("This… isn't… happening!")
            }
        }

        let expectation = expectation(description: "Default test service value called successfully.")

        guard let defaultTestService = GlobalDependencies.default.testService as? DefaultTestService else {
            XCTFail("Uh? default test service dependency not of default type.")
            return
        }
        defaultTestService.testOverride = {
            expectation.fulfill()
        }
        defer {
            defaultTestService.testOverride = nil
        }

        let overwrittenDependencies = GlobalDependencies.default.with(
            override: MockService(),
            for: TestServiceDependencyKey.self
        )

        var resetDependencies = overwrittenDependencies
        resetDependencies.resetToDefault(key: TestServiceDependencyKey.self)

        let testComponent = TestComponent(dependencies: resetDependencies)

        testComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }

    func testOverwrittenIndirectDependency() throws {
        struct MockService: TLAService {
            func tlaServiceTest() {
                expectation.fulfill()
            }

            let expectation: XCTestExpectation
        }

        let mockExpectation = expectation(description: "Mock expectation's `test()` called")
        let mockService = MockService(expectation: mockExpectation)

        let testComponent = TestComponent(
            dependencies: GlobalDependencies.default.with(override: mockService, for: TLAService.DependencyKey.self)
        )
        let childComponent = testComponent.buildChildComponent()

        childComponent.doTheTest()

        waitForExpectations(timeout: 1.0)
    }
}
