//
//  Dependencies.swift
//
//
//  Created by Óscar Morales Vivó on 1/11/23.
//

import Foundation

/**
 Base protocol for dependency injection. It establishes the baseline for building up dependency sub-protocols with
 facilities for overwriting dependencies and instantiating new dependency objects for other types without having
 to drag all dependencies through the app tree.

 Each global service/singleton in use should make itself available through dependency injection by doing the following:
 - Declare a protocol `Sample` (replace `Sample` with whatever makes sense for naming the protocol). Don't suffix
 the protocol name with `Protocol`. The protocol will declare the API that will be visible to the rest of the
 components.
 - Declare a protocol that implements `Dependencies`, for consistency for `Sample` we should name it
 `SampleDependency`. Make sure it's not a generic protocol. It should look like the following:
 ```swift
 protocol SampleDependency: Dependencies {
     var sample: any Sample { get }
 }
 ```
 - Build a default implementation that will be the one in normal use. Let's call this one `DefaultSample`, but there's
 no particular need to adhere to a specific naming convention for it.
 - Declare a dependency key value type that adopts `DependencyKey`. Following along our sample dependency, this is how
 it would look like:
 ```swift
 struct SampleDependencyKey: DependencyKey {
     let defaultValue: any Sample = DefaultSample()
 }
 ```
 - Declare an extension to `GlobalDependencies` that implements `SampleDependency`. The implementation should look as
 follows:
 ```swift
 extension GlobalDependencies: SampleDependency {
     var sample: any Sample {
         return resolveDependency(forKey: SampleDependencyKey.self)
     }
 }
 ```

 Adoption of dependency injection by the various components of the app should be accomplished as follows:
 - Declare a private constant to hold onto the dependencies. This constant should **not** be of type
 `GlobalDependencies` but instead be a union of all the dependencies that the component needs to perform. For example,
 if our component `MyComponent` needs access to `Network` and `Settings`, it will declare its dependencies as follows:
 ```swift
 class MyComponent ... {
     private let dependencies: NetworkDependency & SettingsDependency
 }
 ```
 - This ensures that we keep the dependencies for a given component explicity managed. If you try to use a different one
 you'll need to add its protocol to the dependencies property type, and hopefully you'll give some thought about whether
 you actually need it.
 - Additionally, the component initializer should allow for a dependency parameter, which _should_ be of type
 `GlobalDependencies`. It ought to have a default value of `GlobalDependencies.default`. Example for the above:
 ```swift
 class MyComponent ... {
     init( ... , dependencies: GlobalDependencies = .default) {
         self.dependencies = dependencies
         ...
     }
 }
 ```
 - Use of dependencies within the component is done by just accessing them through the private `dependencies` property.
 - If the component builds other subcomponents —i.e. a view controller presenting another one, or a general model
 building up an object that manages a smaller part, it should pass in its own dependencies, calling `buildGlobal` to
 type-shift them to something that the other component can take. This ensures that overwritten dependencies consistenly
 get passed down to other components. For example:
 ```swift
 class MyComponent ... {
     func doThing(...) {
         ...
         let subComponent = SubComponent( ... , dependencies: dependencies.buildGlobal())
         ...
     }
 }
 ```
 */
public protocol Dependencies {
    /// Build a new ``GlobalDependencies`` from any ``Dependencies``.
    func buildGlobal() -> GlobalDependencies
}

/**
 A macro that sets up a dependency based on the protocol it is attached to.
 - Parameters
   - lowercased: Optional name of the dependency access property, to be used if it is different than `name` with its
 first letter in lowercase.
   - defaultValueType: The type of the default value for the dependency. Must have an initializer with no parameters.
 */
@attached(peer, names: suffixed(Dependency), suffixed(DependencyKey))
public macro Dependency<T>(
    lowercased: StaticString? = nil,
    defaultValueType: T.Type
) = #externalMacro(module: "GlobalDependenciesMacros", type: "DependencyPeers")

/**
 A macro that sets up a dependency whose default implementation is named as the attached protocol prefixed by `Default`.
 - Parameters
   - lowercased: Optional name of the dependency access property, to be used if it is different than `name` with its
 first letter in lowercase.
 */
@attached(peer, names: suffixed(Dependency), suffixed(DependencyKey))
public macro Dependency(
    lowercased: StaticString? = nil
) = #externalMacro(module: "GlobalDependenciesMacros", type: "DependencyPeers")
