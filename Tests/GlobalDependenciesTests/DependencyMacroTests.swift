//
//  DependencyMacroTests.swift
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
    "Dependency": DependencyMacro.self
]
#endif

final class DependencyMacroTests: XCTestCase {
    func testAllDefaultParams() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency
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
                static let defaultValue: any TestService = DefaultTestServiceValueFactory.makeDefaultValue()
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
                static let defaultValue: any URLThingamajig = DefaultURLThingamajigValueFactory.makeDefaultValue()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testDefaultValueFactoryOnly() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency(defaultValueFactory: TestServiceImpl)
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
                static let defaultValue: any TestService = TestServiceImpl.makeDefaultValue()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCustomLowercaseAndDefaultValueFactory() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency(lowercased: "urlThingamajig", defaultValueFactory: URLThingamajigImpl)
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
                static let defaultValue: any URLThingamajig = URLThingamajigImpl.makeDefaultValue()
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
            @Dependency
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
            @Dependency(defaultValueFactory: GiveMeMyImplType())
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

extension DependencyMacroTests {
    func testAccessModifiersAppliedToPeerTypesFilePublic() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency
            public protocol TestService {
                func serviceTest()
            }
            """,
            expandedSource: """
            public protocol TestService {
                func serviceTest()

                typealias Dependency = TestServiceDependency

                typealias DependencyKey = TestServiceDependencyKey
            }

            public protocol TestServiceDependency: Dependencies {
                var testService: any TestService {
                    get
                }
            }

            public struct TestServiceDependencyKey: DependencyKey {
                public static let defaultValue: any TestService = DefaultTestServiceValueFactory.makeDefaultValue()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAccessModifiersAppliedToPeerTypesFileInternal() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency
            internal protocol TestService {
                func serviceTest()
            }
            """,
            expandedSource: """
            internal protocol TestService {
                func serviceTest()

                typealias Dependency = TestServiceDependency

                typealias DependencyKey = TestServiceDependencyKey
            }

            internal protocol TestServiceDependency: Dependencies {
                var testService: any TestService {
                    get
                }
            }

            internal struct TestServiceDependencyKey: DependencyKey {
                internal static let defaultValue: any TestService = DefaultTestServiceValueFactory.makeDefaultValue()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAccessModifiersAppliedToPeerTypesFileprivate() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency
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
                fileprivate static let defaultValue: any TestService = DefaultTestServiceValueFactory.makeDefaultValue()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAccessModifiersAppliedToPeerTypesPrivate() throws {
        #if canImport(GlobalDependenciesMacros)
        assertMacroExpansion(
            """
            @Dependency
            private protocol TestService {
                func serviceTest()
            }
            """,
            expandedSource: """
            private protocol TestService {
                func serviceTest()

                typealias Dependency = TestServiceDependency

                typealias DependencyKey = TestServiceDependencyKey
            }

            private protocol TestServiceDependency: Dependencies {
                var testService: any TestService {
                    get
                }
            }

            private struct TestServiceDependencyKey: DependencyKey {
                fileprivate static let defaultValue: any TestService = DefaultTestServiceValueFactory.makeDefaultValue()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
