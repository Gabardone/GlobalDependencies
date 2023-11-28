//
//  DependenciesMacroTests.swift
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
    "Dependencies": InjectedDependenciesMacro.self
]
#endif

final class DependenciesMacroTests: XCTestCase {
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

                typealias Dependencies = any TestService.Dependency & TLAService.Dependency

                private let dependencies: Dependencies
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testDependenciesTypealiasAccessControl() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependencies(TestService, TLAService)
            public class TestClass {
                func doTheThing() {}
            }
            """,
            expandedSource:
            """
            public class TestClass {
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

    func testNonIdentifierParameterDiagnostic() throws {
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

                typealias Dependencies = any TestService.Dependency & TLAService.Dependency

                private let dependencies: Dependencies
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testNonIdentifierDependencies() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependencies(TestService, GiveMeTheType())
            class TestClass {
                func doTheThing() {}
            }
            """,
            expandedSource:
            """
            class TestClass {
                func doTheThing() {}

                typealias Dependencies = any TestService.Dependency

                private let dependencies: Dependencies
            }
            """,
            diagnostics: [.init(
                id: GlobalDependenciesMacros.DiagnosticMessage.onlyProtocolIdentifiersAllowed.diagnosticID,
                message: GlobalDependenciesMacros.DiagnosticMessage.onlyProtocolIdentifiersAllowed.message,
                line: 1,
                column: 28,
                severity: .error,
                highlight: "GiveMeTheType()"
            )],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
