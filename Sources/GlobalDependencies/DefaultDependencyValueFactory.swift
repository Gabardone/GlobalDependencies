//
//  DefaultDependencyValueFactory.swift
//
//
//  Created by Óscar Morales Vivó on 11/7/23.
//

import Foundation

/**
 A protocol adopted by types that can build the default value for a given dependency.

 Every use of the `Dependency` macro requires the existence of a type that adopts this protocol with a `Value` type that
 adopts the dependency protocol. There is no particular limitation about adopters beyond that. In some cases it may be
 perfectly fine to make the default implementation type itself adopt the protocol, in others —for example when the
 default implementation isn't it's own type but the product of a factory method— building a short `struct` that adopts
 is the better course of action.
 */
public protocol DefaultDependencyValueFactory {
    associatedtype Value

    static func makeDefaultValue() -> Value
}
