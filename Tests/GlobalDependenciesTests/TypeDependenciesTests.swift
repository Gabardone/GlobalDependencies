//
//  TypeDependenciesTests.swift
//
//
//  Created by Óscar Morales Vivó on 10/16/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(GlobalDependenciesMacros)
@testable import GlobalDependenciesMacros

private let testMacros: [String: Macro.Type] = [
    "Dependencies": TypeDependencies.self
]
#endif

final class TypeDependenciesTests: XCTestCase {
    func testAllDefaultParams() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependencies(TestService, TLAService)
            class TestClass {
                func doTheThing() {}
            }
            """,
            expandedSource:
            """
            class TestClass {
                func doTheThing() {}

                public typealias Dependencies = any TestService.Dependency & TLAService.Dependency

                private let dependencies: Dependencies
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
