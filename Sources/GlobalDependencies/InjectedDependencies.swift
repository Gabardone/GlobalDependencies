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
 `let dependencies: Dependencies` stored property to hold onto them. Its access control can be tweaked if needed but
 if possible it's best to leave the default `private`.

 Initialization being individual to each type means the logic for injecting the dependencies will need to be added to
 any initializers that the type has manually, usually by adding a final parameter of the form
 `dependencies: Dependencies = GlobalDependencies.default`.
 - Parameters
   - dependencyAccess: Access control for the generated `dependencies` stored property. Defaults to `.private`. This
 being a macro you should always use a constant whenever you use the parameter or the macro won't be able to generate
 valid code.
   - _: A comma-separated list of dependency protocols. These should be the protocols that have `@Dependency`
 attached to their declaration, not their generated `.Dependency` protocols
 */
@attached(member, names: named(Dependencies), named(dependencies))
public macro InjectedDependencies<each U>(
    dependencyAccess: AccessControl = .private, _: repeat (each U).Type
) = #externalMacro(
    module: "GlobalDependenciesMacros",
    type: "InjectedDependenciesMacro"
)
