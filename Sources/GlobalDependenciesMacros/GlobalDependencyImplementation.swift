//
//  GlobalDependencyImplementation.swift
//
//
//  Created by Óscar Morales Vivó on 10/19/23.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct GlobalDependencyImplementation {}

extension GlobalDependencyImplementation: DeclarationMacro {
    static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in _: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let protocolName = node.argumentList.first?.expression.asIdentifier else {
            // We should only get here on tool error. Let's BOOM away.
            preconditionFailure()
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
