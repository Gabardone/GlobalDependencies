# ``GlobalDependencies``

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

Parking this stuff here until we put it in a better place…

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


## Topics

### Setting up a Dependency

- <doc:DependencySetup>
- ``Dependency(lowercased:defaultValueFactory:)``
- ``Dependency(lowercased:)``
- ``GlobalDependency(type:lowercased:)``
- ``DefaultDependencyValueFactory``
- ``Dependencies``
- ``DependencyKey``

### Injecting Dependencies into Components

- <doc:DependencyInjection>
- ``InjectedDependencies(dependencyAccess:_:)``

### Dependency Overrides

- <doc:DependencyOverride>
- ``GlobalDependencies``
