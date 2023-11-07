//
//  GlobalDependencies.swift
//
//
//  Created by Óscar Morales Vivó on 1/11/23.
//

import Foundation

/**
 Global Dependencies container. This should be the central point of access for app-wide dependencies.

 See the documentation for `Dependencies` for a full explanation of the usage patterns. This type encompasses all of
 the app's dependencies so it gets passed around as an overarching type, which then gets filtered into specific needed
 dependencies within components.
 */
public struct GlobalDependencies {
    /**
     The default environment singleton with no overrides. Use as a default parameter for dependency injection and to
     initialize root dependencies.
     */
    public static let `default` = GlobalDependencies()

    public typealias DependencyKeyPath = PartialKeyPath<GlobalDependencies>

    /**
     Dependency storage.
     - Note: Investigate using `GlobalDependencies` as the root type once Swift 5.6 is out.
     */
    private(set) var overrides = [ObjectIdentifier: Any]()
}

// MARK: - Dependency resolution

public extension GlobalDependencies {
    /**
     Resolves a given dependency.

     This should always be called from the implementation of a dependency property in a dependency protocol. There
     should never be any other reason to call it.

     It will return the override value if any has been set, or the default one if not.
     - Parameter keyPath: Key path to the dependency property.
     - Parameter defaultImplementation: The default implementation to return if there is no override. It is an
     autoclosure so creation of the default can happen lazily and thus avoided if overwritten.
     - Returns: The resolved dependency for the `keyPath` property.
     */
    func resolveDependencyFor<Key: DependencyKey>(key: Key.Type) -> Key.Value {
        if let existingOverride = overrides[ObjectIdentifier(key)] {
            if let typedOverride = existingOverride as? Key.Value {
                return typedOverride
            } else {
                // Log that something is wrong.
                assertionFailure("Dependency override found \(existingOverride) of type \(type(of: existingOverride)). Expected type \(key.Value)")
            }
        }

        // Fallback to the default implementation.
        return key.defaultValue
    }
}

// MARK: - Dependencies implementation.

extension GlobalDependencies: Dependencies {
    public func buildGlobal() -> GlobalDependencies {
        self
    }
}

// MARK: - Dependency override management.

public extension GlobalDependencies {
    /**
     Overrides a dependency property with the given value.

     After this call `value` will be returned for the property at `keyPath`. Keep in mind that this is a value type so
     anytihng that has already had dependencies injected will not change behavior.

     The expected use of this method is to build custom injected dependencies for testing purposes but it might come in
     handy in other circumstances, i.e. alternate setups for certain custom builds/releases.
     - Parameter keyPath The accessor's keypath.
     - Parameter value The overriding instance, of the same —usually `protocol`— type.
     */
    mutating func override<Key: DependencyKey>(key: Key.Type, with value: Key.Value) {
        overrides[ObjectIdentifier(key)] = value
    }

    /**
     Resets a dependency property to its default value.

     You shouldn't use this often if at all but in case it is needed this method allows the default implementation of a
     dependency property to be kept fully private to anyone needing the dependency itself.
     - Parameter keyPath The accessor's keypath.
     */
    mutating func resetToDefault(key: (some DependencyKey).Type) {
        overrides.removeValue(forKey: ObjectIdentifier(key))
    }

    /**
     If you only need to override a single dependency for testing purposes, this utility saves a lot of verbosity by
     producing a new global dependencies with the given one injected.
     - Parameter override: The value that will override the dependency for the returned `GlobalDependencies`
     - Parameter keyPath: Key path to the dependency property we want to override.
     - Returns: A new `GlobalDependencies` identical to the caller but for returning `override` for
     `dependencies[keyPath: keyPath`.
     */
    func with<Key: DependencyKey>(override: Key.Value, for key: Key.Type) -> GlobalDependencies {
        var updatedDependency = self
        updatedDependency.override(key: key, with: override)
        return updatedDependency
    }
}

/**
 Implements a dependency on the `GlobalDependencies` type.

 Since Swift macros cannot (as of Swift 5.9) declare extensions, this macro will be invoked _inside_ a manually declared
  `extension GlobalDependencies: MyProtocol.Dependency`. And since the macro doesn't have access to its contextual
 semantics you'll have to repeat the protocol name (`MyProtocol` in this contrived example) in the corresponding
 parameter of the macro 🤷🏽‍♂️.
 - Parameters
   - type: Type of the dependency. Should be the same as the property vended by the dependency protocol that the
 extension is adopting.
   - lowercased: Name of the dependency accessor property. You only need to pass a value if it is different than `name`
 with its first letter lowercased.
 */
@freestanding(declaration, names: arbitrary)
public macro GlobalDependency<T>(type: T.Type, lowercased: StaticString? = nil) = #externalMacro(
    module: "GlobalDependenciesMacros",
    type: "GlobalDependencyMacro"
)
