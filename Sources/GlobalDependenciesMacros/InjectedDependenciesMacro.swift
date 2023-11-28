//
//  InjectedDependenciesMacro.swift
//
//
//  Created by Óscar Morales Vivó on 10/15/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct InjectedDependenciesMacro {}

extension InjectedDependenciesMacro: MemberMacro {
    private static let dependencyAccessLabel = "dependencyAccess"

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
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard case let .argumentList(arguments) = node.arguments else {
            return []
        }

        let dependenciesAccessControl: String
        let adoptionArguments: any Collection<LabeledExprSyntax>
        if let dependencyAccessArgument = arguments.first(where: { argument in
            argument.label?.text == dependencyAccessLabel
        }) {
            guard let accessIdentifier = dependencyAccessArgument.expression.as(MemberAccessExprSyntax.self) else {
                // We should only get here by tool error.
                fatalError()
            }

            dependenciesAccessControl = accessIdentifier.declName.baseName.text
            adoptionArguments = arguments.dropFirst()
        } else {
            dependenciesAccessControl = "private"
            adoptionArguments = arguments
        }

        // Grab the adoptions identifiers.
        let adoptions = adoptionArguments.compactMap { element -> String? in
            if let identifier = element.expression.asProtocolIdentifier {
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

        let declarationAccessModifier = declaration.modifiers.extractAccessModifier()
        let typealiasAccessModifier = if let declarationAccessModifier {
            "\(declarationAccessModifier)"
        } else {
            ""
        }

        return [
            """
            \(raw: typealiasAccessModifier)typealias Dependencies = any \(raw: adoptions.joined(separator: " & "))
            """,
            """
            \(raw: dependenciesAccessControl) let dependencies: Dependencies
            """
        ]
    }
}

extension DiagnosticMessage {
    static let onlyProtocolIdentifiersAllowed = DiagnosticMessage(
        message: "InjectedDependencies macro can only take protocol identifiers.",
        diagnosticID: "only-protocol-identifiers-allowed"
    )
}
