//
//  InjectedDependencies.swift
//
//
//  Created by Óscar Morales Vivó on 11/15/23.
//

import Foundation

/**
 A macro that declares the dependencies of the attached type and sets it up for their injection.

 The macro will declare a `Dependencies` type matching the dependencies for all the given protocols and a
 `private let dependencies: Dependencies` stored property to hold onto them.

 Initialization being individual to each type means the logic for injecting the dependencies will need to be added to
 any initializers that the type has manually, usually by adding a final parameter of the form
 `dependencies: Dependencies = GlobalDependencies.default`.
 - Parameter _: A comma-separated list of dependency protocols. These should be the protocols that have `@Dependency`
 attached to their declaration, not their generated `.Dependency` protocols
 */
@attached(member, names: named(Dependencies), named(dependencies))
public macro InjectedDependencies<each U>(_: repeat (each U).Type) = #externalMacro(
    module: "GlobalDependenciesMacros",
    type: "InjectedDependenciesMacro"
)
