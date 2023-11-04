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

public struct DependencyPeers {}

extension DependencyPeers: PeerMacro {
    private static let defaultValueTypeLabel = "defaultValueType"
    private static let lowercasedLabel = "lowercased"

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = node.arguments.flatMap { arguments in
            if case let .argumentList(argumentList) = arguments {
                return argumentList
            } else {
                return nil
            }
        }

        // Extract the protocol name from the protocol declaration.
        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self),
              let protocolName = protocolDeclaration.name.identifier else {
            context.diagnose(.init(
                node: declaration,
                message: DiagnosticMessage.nonProtocolAttachee,
                highlights: [Syntax(declaration)]
            ))
            return []
        }

        // Extract visibility modifiers if any (they will need applying to the peer types for things to work).
        let accessModifier: DeclModifierSyntax? = protocolDeclaration.modifiers.extractAccessModifier()

        // Process the lowercased identifier for the dependency protocol accessor property.
        let lowercasedPropertyIdentifier = arguments.extractLowercasedIdentifier(protocolName: protocolName)

        // Process the type name for the default implementation.
        let defaultValueTypeIdentifier: String
        if let defaultValueArgument = arguments?.first(where: { argument in
            argument.label?.text == defaultValueTypeLabel
        }) {
            guard let defaultValueName = defaultValueArgument.expression.asIdentifier else {
                context.diagnose(.init(
                    node: defaultValueArgument,
                    message: DiagnosticMessage.defaultImplementationNotATypeIdentifier,
                    highlights: [Syntax(defaultValueArgument.expression)]
                ))
                return []
            }
            defaultValueTypeIdentifier = "\(defaultValueName)"
        } else {
            defaultValueTypeIdentifier = "Default\(protocolName)"
        }

        return [
            """
            \(raw: accessModifier?.name ?? "")protocol \(raw: protocolName)Dependency: Dependencies {
                var \(raw: lowercasedPropertyIdentifier): any \(raw: protocolName){ get }
            }
            """,
            """
            \(raw: accessModifier?.name ?? "")struct \(raw: protocolName)DependencyKey: DependencyKey {
                \(raw: accessModifier?.name ?? "")static let defaultValue: any \(raw: protocolName)= \(raw: defaultValueTypeIdentifier)()
            }
            """
        ]
    }
}

extension DependencyPeers: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in _: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self),
              let protocolName = protocolDeclaration.name.identifier else {
            // The other macro method will take care of the diagnostic.
            return []
        }

        return [
            """
            typealias Dependency = \(raw: protocolName)Dependency
            """,
            """
            typealias DependencyKey = \(raw: protocolName)DependencyKey
            """
        ]
    }
}

extension DiagnosticMessage {
    static let nonProtocolAttachee = DiagnosticMessage(
        message: "Dependency macro can only be applied to protocol declarations.",
        diagnosticID: "non-protocol-attachee"
    )

    static let defaultImplementationNotATypeIdentifier = DiagnosticMessage(
        message: "Default implementation type parameter must be a concrete type identifier.",
        diagnosticID: "default-implementation-not-a-type"
    )
}
