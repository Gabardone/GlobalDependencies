//
//  DependencyKey.swift
//
//
//  Created by Óscar Morales Vivó on 10/13/23.
//

import Foundation

/**
 A key for accessing individual dependencies, based on `SwiftUI.EnvironmentKey`

 Dependencies work similarly to SwiftUI's environment and thus they can be keyed similarly to ensure both uniqueness
 when extending `GlobalDependencies` and safe access to them.

 Normally implementations of this type will be created by the ``Dependency(lowercased:defaultValueFactory:)`` macro and
 the implementation will use the ``DefaultDependencyValueFactory`` protocol to feed `defaultValue`. But a manual
 implementation can be built by hand if needed. In such case for a given `ExampleProtocol` depencency `Value` should be
 `any ExampleProtocol`.
 */
public protocol DependencyKey {
    /**
     The dependency value associated with the key. Normally of an existential type for the keyed dependency protocol.
     */
    associatedtype Value

    /**
     The default value used for the dependency if no overwrite is beind made for the key using
     ``GlobalDependencies/override(key:with:)``.
     */
    static var defaultValue: Value { get }
}
