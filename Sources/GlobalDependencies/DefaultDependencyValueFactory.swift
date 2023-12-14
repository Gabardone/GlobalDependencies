//
//  DefaultDependencyValueFactory.swift
//
//
//  Created by Óscar Morales Vivó on 11/7/23.
//

import Foundation

/**
 A protocol adopted by types that can build the default value for a dependency.

 Every use of the `Dependency` macro requires the existence of a type that adopts the `DefaultDependencyValueFactory`
 protocol with a `Value` type that can be passed in to a dependency protocol existential. There is no particular
 limitation about adopters beyond that. In some cases it may be perfectly fine to make the default implementation type
 itself adopt the protocol, in others —for example when the default implementation isn't it's own type but the product
 of a factory method— building a short `struct` that adopts is the better course of action.

 If you are building your own type to feed a dependency's default value you can make it `private` as long as it's in the
 same file and `internal` if it's in the same module. If you name it `Default<dependency name>ValueFactory` you can
 omit the factory type name from the `@Dependency` macro.
 */
public protocol DefaultDependencyValueFactory {
    /**
     The value returned by `makeDefaultValue` method.

     The type returned should adopt any dependency protocol that it will be used as a default value factory for. The
     same type can be used to feed default values to more than one dependency if they are compatible and it otherwise
     makes sense to do so.
     */
    associatedtype Value

    /**
     Returns a default value.

     The method implementation may either return a `static` value or build a new one each time.

     Since the resulting value is stored in a `static` stored property in `GlobalDependencies` the method should
     normally only be called once, when the dependency is first accessed in `GlobalDependencies.default`.

     However if an overwitten dependency is reset to default using ``GlobalDependencies/resetToDefault(key:)`` a new
     call to `makeDefaultValue()` will be made to fetch that reset value.
     */
    static func makeDefaultValue() -> Value
}
