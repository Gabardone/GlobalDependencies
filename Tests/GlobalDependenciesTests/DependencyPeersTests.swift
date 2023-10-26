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
}
