//
//  TLAService.swift
//
//
//  Created by Óscar Morales Vivó on 10/22/23.
//

@testable import GlobalDependencies
import XCTest

/// Another depdendency for child dependency testing.
@Dependency(lowercased: "tlaService", defaultValueType: TestManagerImpl)
protocol TLAService {
    func tlaServiceTest()
}

struct TestManagerImpl: TLAService {
    func tlaServiceTest() {
        XCTFail("No tests expected to call this so far")
    }
}

extension GlobalDependencies: TLAServiceDependency {
    #GlobalDependency(type: TLAService, lowercased: "tlaService")
}
