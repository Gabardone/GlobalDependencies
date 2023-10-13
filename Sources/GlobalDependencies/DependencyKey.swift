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
 */
public protocol DependencyKey {
    associatedtype Value

    static var defaultValue: Self.Value { get }
}
