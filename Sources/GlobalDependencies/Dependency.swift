//
//  Dependency.swift
//
//
//  Created by Óscar Morales Vivó on 11/7/23.
//

import Foundation

/**
 A macro that sets up a dependency based on the protocol it is attached to.

 Due to limitations of the Swift macro system (as of Swift 5.9) it is better to have a 1 to 1 correspondence between a
 protocol and a dependency type. This allows the `Dependency` macro to automatically build up most of the auxiliary
 types needed to manage the protocol as a dependency.

 The macro will declare two additional types and also insert them as a `typealias` into the attachee protocol. One is a
 protocol of the same name as the attachee, postfixed with `Dependency` and with a single property that returns an `any
 Attachee`. This type will be adopted by `GlobalDependencies` in an extension —usually through usage of the
 `GlobalDependency` macro— and will be how we retrieve this dependency for use in our code.

 The other is a key type, adopting `DependencyKey`, which will be used by `GlobalDependencies` for override management.

 If despite all the above a manual dependency declaration is needed you can you can always just check the code generated
 by the macro when applied to a random protocol and manually adapt that to your needs.
 - Parameters
   - lowercased: Optional name of the dependency access property, to be used if it should be different than `name` with
 its first letter in lowercase.
   - defaultValueFactory: A type that adopts `DefaultDependencyValueFactory` and whose `Value` associated type adopts
 the protocol that the macro is attached to. The latter constraint can't be modeled in the macro declaration as of Swift
 5.9 but compilation of the generated code will helpfully fail if that's not the case.
 */
@attached(peer, names: suffixed(Dependency), suffixed(DependencyKey))
@attached(member, names: named(Dependency), named(DependencyKey))
public macro Dependency<T: DefaultDependencyValueFactory>(
    lowercased: StaticString? = nil,
    defaultValueFactory: T.Type
) = #externalMacro(
    module: "GlobalDependenciesMacros",
    type: "DependencyMacro"
)

/**
 Variant of the `Dependency` macro that does not take a default value factory type.

 If the default value type for the dependency implementation is named `Default<API protocol name>Factory` you can use
 this variant of the macro and it will catch on it.

 Because there is no generic argument it has to be declared separately from the version with a default value type as
 the compiler wouldn't know what type to use without the presence of the parameter that uses it.

 Otherwise the documentation of the fully featured macro applies to its behavior.
 - Parameters
   - lowercased: Optional name of the dependency access property, to be used if it should be different than `name` with
 its first letter in lowercase.
  */
@attached(peer, names: suffixed(Dependency), suffixed(DependencyKey))
@attached(member, names: named(Dependency), named(DependencyKey))
public macro Dependency(lowercased: StaticString? = nil) = #externalMacro(
    module: "GlobalDependenciesMacros",
    type: "DependencyMacro"
)
