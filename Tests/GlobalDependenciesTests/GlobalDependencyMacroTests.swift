//
//  GlobalDependencyMacroTests.swift
//
//
//  Created by Óscar Morales Vivó on 10/22/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(GlobalDependenciesMacros)
@testable import GlobalDependenciesMacros

private let testMacros: [String: Macro.Type] = [
    "GlobalDependency": GlobalDependencyMacro.self
]
#endif

final class GlobalDependencyMacroTests: XCTestCase {
    func testWithDefaultParam() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            extension GlobalDependencies: TestServiceDependency {
                #GlobalDependency(any TestService)
            }
            """,
            expandedSource: """
            extension GlobalDependencies: TestServiceDependency {
                var testService: any TestService {
                    resolveDependencyFor(key: TestService.DependencyKey.self)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testWithCustomLowercase() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            extension GlobalDependencies: TLAService.Dependency {
                #GlobalDependency(TLAService, lowercased: "tlaService")
            }
            """,
            expandedSource: """
            extension GlobalDependencies: TLAService.Dependency {
                var tlaService: any TLAService {
                    resolveDependencyFor(key: TLAService.DependencyKey.self)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testWithDiagnostics() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            extension GlobalDependencies: TLAService.Dependency {
                #GlobalDependency(GiveMeTheType(), lowercased: "tlaService")
            }
            """,
            expandedSource: """
            extension GlobalDependencies: TLAService.Dependency {
            }
            """,
            diagnostics: [.init(
                id: GlobalDependenciesMacros.DiagnosticMessage.nonProtocolImplementationParameter.diagnosticID,
                message: GlobalDependenciesMacros.DiagnosticMessage.nonProtocolImplementationParameter.message,
                line: 2,
                column: 23,
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
