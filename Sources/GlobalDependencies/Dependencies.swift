//
//  Dependencies.swift
//
//
//  Created by Óscar Morales Vivó on 1/11/23.
//

import Foundation

/**
 Base protocol for vending dependencies for injection.

 As part of declaring a dependency, we need an implementation of this protocol that both vends the actual dependency
 item and can build back a `GlobalDependencies` value to pass on to child components. This allows for build up of app
 components without needing to know what dependencies they require are or make dependencies transitive.

 Most of the time implementations of this protocol will be built by applying the
 ``Dependency(lowercased:defaultValueFactory:)`` macro to a protocol that declares the actual dependency functionality
 —what we call the "API protocol" throughout the documentation—, but if that is not viable for some reason please
 1) file a ticket and 2) Build it manually as close as done by the macro itself as possible.
 */
public protocol Dependencies {
    /// Build a new ``GlobalDependencies`` from any ``Dependencies``.
    func buildGlobal() -> GlobalDependencies
}
