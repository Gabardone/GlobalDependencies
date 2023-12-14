# ``GlobalDependencies``

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

The GlobalDependencies package lets you easily declare protocol-based dependencies that are both easy to manage during
regular development and help keep your logic easy to test. With just a few lines of macro-sprinkled code you can turn
a `protocl` façade for the functionality that your dependency vends into something that gets automatically built,
lazily, whenever needed, and that allows clear visibility to the dependencies of any given component while adding
negligible friction.

## Topics

### Learn to use GlobalDependencies

- <doc:Using-GlobalDependencies>

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
