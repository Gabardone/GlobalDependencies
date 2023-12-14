//
//  TLAService.swift
//
//
//  Created by Óscar Morales Vivó on 10/22/23.
//

@testable import GlobalDependencies
import XCTest

/// Another depdendency for child dependency testing.
@Dependency(lowercased: "tlaService", defaultValueFactory: TestManagerImpl)
protocol TLAService {
    func tlaServiceTest()
}

struct TestManagerImpl {}

extension TestManagerImpl: TLAService {
    func tlaServiceTest() {
        XCTFail("No tests expected to call this so far")
    }
}

extension TestManagerImpl: DefaultDependencyValueFactory {
    static func makeDefaultValue() -> TestManagerImpl {
        TestManagerImpl()
    }
}

extension GlobalDependencies: TLAServiceDependency {
    #GlobalDependency(type: TLAService, lowercased: "tlaService")
}
