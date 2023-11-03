//
//  TypeDependencies.swift
//
//
//  Created by Óscar Morales Vivó on 10/15/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TypeDependencies {}

extension TypeDependencies: MemberMacro {
    private enum MacroError: Error {
        case adoptionParameterNotAProtocolIdentifier

        var localizedDescription: String {
            switch self {
            case .adoptionParameterNotAProtocolIdentifier:
                return "Adoption parameters must be protocol identifiers."
            }
        }
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf _: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard case let .argumentList(arguments) = node.arguments else {
            return []
        }

        // Grab the adoptions identifiers.
        let adoptions = arguments.compactMap { element -> String? in
            if let identifier = element.expression.asIdentifier {
                return identifier.appending(".Dependency")
            } else {
                // Add diagnostics if it's not an identifier. Further analysis will be on the compiler.
                context.diagnose(.init(
                    node: element,
                    message: DiagnosticMessage.onlyProtocolIdentifiersAllowed,
                    highlights: [Syntax(element.expression)]
                ))
                return nil
            }
        }

        return [
            """
            public typealias Dependencies = any \(raw: adoptions.joined(separator: " & "))
            """,
            """
            private let dependencies: Dependencies
            """
        ]
    }
}

extension DiagnosticMessage {
    static let onlyProtocolIdentifiersAllowed = DiagnosticMessage(
        message: "Dependencies macro can only take protocol identifiers.",
        diagnosticID: "only-protocol-identifiers-allowed"
    )
}
