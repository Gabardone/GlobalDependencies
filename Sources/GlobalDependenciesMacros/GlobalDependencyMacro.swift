//
//  GlobalDependencyMacro.swift
//
//
//  Created by Óscar Morales Vivó on 10/19/23.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct GlobalDependencyMacro {}

extension GlobalDependencyMacro: DeclarationMacro {
    static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let protocolArgument = node.argumentList.first else {
            // This should only happen on tool error. BOOM.
            preconditionFailure()
        }

        guard let protocolName = protocolArgument.expression.asProtocolIdentifier else {
            context.diagnose(.init(
                node: protocolArgument,
                message: DiagnosticMessage.nonProtocolImplementationParameter,
                highlights: [Syntax(protocolArgument.expression)]
            ))
            return []
        }

        // Process the lowercased identifier for the dependency protocol accessor property.
        let lowercasedPropertyIdentifier = node.argumentList.extractLowercasedIdentifier(protocolName: protocolName)

        return [
            """
            var \(raw: lowercasedPropertyIdentifier): any \(raw: protocolName) {
                resolveDependencyFor(key: \(raw: protocolName).DependencyKey.self)
            }
            """
        ]
    }
}

extension DiagnosticMessage {
    static let nonProtocolImplementationParameter = DiagnosticMessage(
        message: "Global dependency macro parameter can only be a protocol identifier.",
        diagnosticID: "non-protocol-implementation-parameter"
    )
}
