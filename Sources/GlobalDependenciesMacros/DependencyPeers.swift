//
//  DependencyPeers.swift
//
//
//  Created by Óscar Morales Vivó on 10/13/23.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DependencyPeers {
}

extension DependencyPeers: PeerMacro {
    private static let defaultValueTypeLabel = "defaultValueType"
    private static let lowercasedLabel = "lowercased"

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let arguments = node.arguments.flatMap { arguments in
            if case let .argumentList(argumentList) = arguments {
                return argumentList
            } else {
                return nil
            }
        }

        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
            // TODO: Add a diagnostic complaining that this can only be attached to a protocol.
            return [DeclSyntax(declaration)]
        }

        // The actual protocol name from the decorated declaration.
        let protocolName = protocolDeclaration.name

        // Process the lowercased identifier for the dependency protocol accessor property.
        let lowercasedPropertyIdentifier: String
        if let lowercasedArgument = arguments?.first(where: { argument in
            argument.label?.text == lowercasedLabel
        }) {
            guard let lowercasedString = lowercasedArgument.expression.as(StringLiteralExprSyntax.self) else {
                // This should only happen if the tools f**k up.
                preconditionFailure()
            }
            lowercasedPropertyIdentifier = "\(lowercasedString.segments)"
        } else {
            // Just lowercase the first letter.
            let uppercased = protocolName.text
            lowercasedPropertyIdentifier = uppercased[uppercased.startIndex].lowercased() + uppercased.dropFirst()
        }

        // Process the type name for the default implementation.
        let defaultValueTypeIdentifier: String
        if let defaultValueArgument = arguments?.first(where: { argument in
            argument.label?.text == defaultValueTypeLabel
        }) {
            guard let defaultValueName = defaultValueArgument.expression.as(DeclReferenceExprSyntax.self) else {
                // TODO: Add a diagnostic complaining that this can only be attached to a type identifier.
                return [DeclSyntax(declaration)]
            }
            defaultValueTypeIdentifier = "\(defaultValueName)"
        } else {
            defaultValueTypeIdentifier = "Default\(protocolName.text)"
        }

        return [
"""
protocol \(raw: protocolName.text)Dependency: Dependencies {
    var \(raw: lowercasedPropertyIdentifier): any \(protocolName){ get }
}
""",
"""
struct \(raw: protocolName.text)DependencyKey: DependencyKey {
    static let defaultValue: any \(protocolName)= \(raw: defaultValueTypeIdentifier)()
}
"""
        ]
    }
}
