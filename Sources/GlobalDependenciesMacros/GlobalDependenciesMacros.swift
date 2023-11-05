import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct GlobalDependenciesPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DependencyPeers.self,
        GlobalDependencyImplementation.self,
        TypeDependencies.self
    ]
}

private let lowercasedLabel = "lowercased"

extension ExprSyntax {
    var asIdentifier: String? {
        `as`(DeclReferenceExprSyntax.self)?.baseName.identifier
    }
}

extension TokenSyntax {
    var identifier: String? {
        if case let .identifier(result) = tokenKind {
            return result
        } else {
            return nil
        }
    }
}

extension LabeledExprListSyntax? {
    func extractLowercasedIdentifier(protocolName: String) -> String {
        if let lowercasedArgument = self?.first(where: { argument in
            argument.label?.text == lowercasedLabel
        }) {
            guard let lowercasedString = lowercasedArgument.expression.as(StringLiteralExprSyntax.self) else {
                // This should only happen if the tools f**k up.
                preconditionFailure()
            }
            return "\(lowercasedString.segments)"
        } else {
            // Just lowercase the first letter.
            return protocolName[protocolName.startIndex].lowercased() + protocolName.dropFirst()
        }
    }
}

extension LabeledExprListSyntax {
    func extractLowercasedIdentifier(protocolName: String) -> String {
        let optional: LabeledExprListSyntax? = self
        return optional.extractLowercasedIdentifier(protocolName: protocolName)
    }
}

extension DeclModifierListSyntax {
    func extractAccessModifier() -> DeclModifierSyntax? {
        for modifier in self {
            if case let .keyword(accessModifier) = modifier.name.tokenKind {
                switch accessModifier {
                case .fileprivate, .internal, .private, .public:
                    return modifier

                default:
                    break
                }
            }
        }

        return nil
    }
}

struct DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    init(message: String, diagnosticID: String) {
        self.message = message
        self.diagnosticID = .init(domain: "sofware.softuer.GlobalDependencies", id: diagnosticID)
    }

    let message: String

    let diagnosticID: MessageID

    let severity: DiagnosticSeverity = .error
}
