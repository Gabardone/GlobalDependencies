//
//  DependencyPeersTests.swift
//
//
//  Created by Óscar Morales Vivó on 10/15/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(GlobalDependenciesMacros)
@testable import GlobalDependenciesMacros

private let testMacros: [String: Macro.Type] = [
    "Dependency": DependencyPeers.self
]
#endif

final class DependencyPeersTests: XCTestCase {
    func testAllDefaultParams() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency()
            protocol TestService {
                func serviceTest()
            }
            """,
            expandedSource: """
            protocol TestService {
                func serviceTest()

                typealias Dependency = TestServiceDependency

                typealias DependencyKey = TestServiceDependencyKey
            }

            protocol TestServiceDependency: Dependencies {
                var testService: any TestService {
                    get
                }
            }

            struct TestServiceDependencyKey: DependencyKey {
                static let defaultValue: any TestService = DefaultTestService()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCustomLowercaseOnly() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency(lowercased: "urlThingamajig")
            protocol URLThingamajig {
                func doTheThing()
            }
            """,
            expandedSource: """
            protocol URLThingamajig {
                func doTheThing()

                typealias Dependency = URLThingamajigDependency

                typealias DependencyKey = URLThingamajigDependencyKey
            }

            protocol URLThingamajigDependency: Dependencies {
                var urlThingamajig: any URLThingamajig {
                    get
                }
            }

            struct URLThingamajigDependencyKey: DependencyKey {
                static let defaultValue: any URLThingamajig = DefaultURLThingamajig()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testDefaultValueTypeOnly() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency(defaultValueType: TestServiceImpl)
            protocol TestService {
                func serviceTest()
            }
            """,
            expandedSource: """
            protocol TestService {
                func serviceTest()

                typealias Dependency = TestServiceDependency

                typealias DependencyKey = TestServiceDependencyKey
            }

            protocol TestServiceDependency: Dependencies {
                var testService: any TestService {
                    get
                }
            }

            struct TestServiceDependencyKey: DependencyKey {
                static let defaultValue: any TestService = TestServiceImpl()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCustomLowercaseAndDefaultValueType() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency(lowercased: "urlThingamajig", defaultValueType: URLThingamajigImpl)
            protocol URLThingamajig {
                func doTheThing()
            }
            """,
            expandedSource: """
            protocol URLThingamajig {
                func doTheThing()

                typealias Dependency = URLThingamajigDependency

                typealias DependencyKey = URLThingamajigDependencyKey
            }

            protocol URLThingamajigDependency: Dependencies {
                var urlThingamajig: any URLThingamajig {
                    get
                }
            }

            struct URLThingamajigDependencyKey: DependencyKey {
                static let defaultValue: any URLThingamajig = URLThingamajigImpl()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAccessModifiersAppliedToPeerTypes() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency()
            fileprivate protocol TestService {
                func serviceTest()
            }
            """,
            expandedSource: """
            fileprivate protocol TestService {
                func serviceTest()

                typealias Dependency = TestServiceDependency

                typealias DependencyKey = TestServiceDependencyKey
            }

            fileprivate protocol TestServiceDependency: Dependencies {
                var testService: any TestService {
                    get
                }
            }

            fileprivate struct TestServiceDependencyKey: DependencyKey {

                fileprivate static let defaultValue: any TestService = DefaultTestService()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testDiagnosticWhenAppliedToNonProtocol() throws {
        #if canImport(GlobalDependenciesMacros)
        let declaredExpression =
            """
            @Dependency()
            struct SomeStruct {
                func serviceTest() {}
            }
            """
        let expandedExpression =
            """
            struct SomeStruct {
                func serviceTest() {}
            }
            """
        assertMacroExpansion(
            declaredExpression,
            expandedSource: expandedExpression,
            diagnostics: [.init(
                id: GlobalDependenciesMacros.DiagnosticMessage.nonProtocolAttachee.diagnosticID,
                message: GlobalDependenciesMacros.DiagnosticMessage.nonProtocolAttachee.message,
                line: 1,
                column: 1,
                severity: .error,
                highlight: declaredExpression
            )],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testDiagnosticWhenDefaultTypeNotIdentifier() throws {
        #if canImport(GlobalDependenciesMacros)
        let declaredExpression =
            """
            @Dependency(defaultValueType: GiveMeMyImplType())
            protocol TestService {
                func serviceTest()
            }
            """
        let expandedExpression =
            """
            protocol TestService {
                func serviceTest()

                typealias Dependency = TestServiceDependency

                typealias DependencyKey = TestServiceDependencyKey
            }
            """
        assertMacroExpansion(
            declaredExpression,
            expandedSource: expandedExpression,
            diagnostics: [.init(
                id: GlobalDependenciesMacros.DiagnosticMessage.defaultImplementationNotATypeIdentifier.diagnosticID,
                message: GlobalDependenciesMacros.DiagnosticMessage.defaultImplementationNotATypeIdentifier.message,
                line: 1,
                column: 13,
                severity: .error,
                highlight: "GiveMeMyImplType()"
            )],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
