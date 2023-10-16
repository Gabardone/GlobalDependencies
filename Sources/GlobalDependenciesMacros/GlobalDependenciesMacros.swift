import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct GlobalDependenciesPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DependencyPeers.self
    ]
}
