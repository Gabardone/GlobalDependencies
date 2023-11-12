# GlobalDependencies
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![MIT License](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://mit-license.org/)
[![Platforms](https://img.shields.io/badge/platform-ios%20%7C%20osx%20%7C%20watchos%20%7C%20tvos-%23989898)](https://apple.com/developer)

This is a simple dependency injection framework good for managing global dependencies (app-level singletons basically)
in small and medium-sized apps. Its earlier versions have been used successfully in several small personal projects and
a mid-sized commercially released app.

It's meant to add as little friction as possible to the task of injecting dependencies so early stage apps can still
take on the benefits of dependency injection (better testability, easier maintenance and changes in dependencies)
without slowing down the pace of development.

As of version 3 and up, the package leans heavily on the use of Swift macros so support for Xcode 15 and the Swift 5.9
toolchain or newer are required.

## Adoption

If the instructions here are not clear enough you can also check additional instructions on how to use the dependency
injection system in `Dependencies.swift` as well as an example of use in the test target of the framework.

For the sake of this example let's assume we want to do dependency injection on `URLSession' so we can mock network
data fetch in tests.

And remember that RINAC (README Is Not a Compiler).

### 1. Declare a protocol to façade the functionality

All dependencies that we want to integrate in this depdendency injection system ought to hide away behind a protocol.
four our example we'll declare a `RemoteDataFetch' protocol with a similar API as the one we want to façade from
`URLSession`

```swift
protocol RemoteDataFetch: Dependencies {
    func data(from url: URL) async throws -> Data
}
```

### 2. Build a default implementation

Build a default implementation to use within the app. Whether this default implementation is complete or not doesn't
matter for the purposes of this exercise, leave it as an actual mock if unblocking other work is more important than
finalizing that default implementation.

In this case we can just extend `URLSession` to adopt the protocol with a bit of extra work.

```swift
extension URLSession: RemoteDataFetch {
    func data(from url: URL) async throws -> Data {
        let (data, response) = try await data(from: url, delegate: nil)
        guard response.isValid else {
            throw BadResponse
        }
        
        return data
    }
}
```

### 3. Declare a dependency protocol

The dependency will be vended through a property, which will hide its implementation behind the protocol we declared on
step #1. As follows for the example:

```swift
protocol RemoteDataFetchDependency {
    var remoteDataFetch: any RemoteDataFetch { get }
}
```

### 4. Add an extension to `GlobalDepdendencies` that implements the new dependency protocol and resolves it.

The accessor for the dependency always takes the same shape. For the case of `URLSession` we can just use
`URLSession.shared` as the default, for your own types you'll want to hold onto a private singleton nearby.

```swift
extension GlobalDependencies: RemoteDataFetchDependency {
    var remoteDataFetch: RemoteDataFetch {
        return resolveDependency(forKeyPath: \.remoteDataFetch, defaultImplementation: URLSession.shared)
    }
}
```

### 5. Add dependency injection to the app components that require it.

There's several steps to ensuring dependency management is… well managed within an app's components. Fortunately they
are all very simple to follow.

#### 5.1 Add a private `dependencies` property that holds onto injected dependencies.

It's important to keep dependencies managed by making that property be of the union of all dependency protocol types
instead of `GlobalDependency`. That keeps dependencies visible and makes them much more straightforward to manage. I.e.
if a component's `dependency` property is the union of half a dozen protocols you may be taking in too much there.

Let's assume we're creating an image cache (probably a dependency itself but we'll leave that off the example) that
needs both network and local (via `protocol LocalDataFetchDependency`) access to get its data. It would look as follows:

```swift
class ImageCache {
    [...]

    private let dependencies: any (RemoteDataFetchDependency & LocalDataFetchDependency)
    
    [...]
}
```

#### 5.2 Initialize your component with global dependencies.

For the sake of minimalistic adoption it's best to limit the explicit naming of dependencies to the `dependencies`
property and just take in `GlobalDependencies` at initialization. Alternatively and with a slight increase of friction
you can declare a `typealias` with the union of dependencies needed and use that both for the property and any 
initializers (not shown in these examples).

For our `ImageCache` type it would look as follows:

```swift
class ImageCache {
    [...]
    
    init(/*any other parameters, */dependencies: GlobalDependencies = .default) {
        self.dependencies = dependencies
        // Initialize other stuff
        [...]
    }
    
    [...]
}
```

#### 5.3 Pass in the dependencies to any newly created components

To make sure that dependency overrides stick, you have to make sure to initialize the dependencies of any component
you create with the ones you have. This just requires using `buildGlobal` on any dependencies you're holding onto
to unwrap back into a `GlobalDependencies` value that can fulfill whatever depdendencies the next component has (this
avoids having to wire down dependency overrides through component trees just because some leaf node has different
dependencies than the branches above it).

In our contrived example we're going to say that our `ImageCache` has a
`lazy var localResourceManager: LocalResourceManager` that depends on… whatever it wants, really. It would look as
follows:

```swift
class ImageCache {
    [...]
    
    lazy var localResourceManager: LocalResourceManager = {
        LocalResourceManager(/*Other parameters, */dependencies: dependencies.buildGlobal())
    }()
    
    [...]
}
```

### 6. Mock and override dependencies for tests.

To build tests for components that have dependencies, all you have to do is build a mock implementation of the
dependency-vended protocol and overwrite the dependency with it.

#### 6.1 Build a Mock

Just like any other mock, really. Either build them on the fly or build a configurable one for use in several tests.

Let's take the latter approach for our example (READMEINAC = README Is Not a Compiler).

```swift
class MockRemoteDataFetch: RemoteDataFetch {
    var dataFromURLOverride: ((URL) async throws -> Data)?

    func data(from url: URL) async throws -> Data {
        try await dataFromURLOverride?(url) ?? throw UnexpectedCallError
    }
}
```

#### 6.2 Override the dependency when setting up a test.

If it's always the same override you can just take care of the matter on the test class' `setUp()` method, otherwise
just run the logic while setting up the individual test proper.

Here is an example for a test on `ImageCache` that verifies that the type reacts properly to a network data fetch error
using the mock above.

```swift
class ImageCacheTests: XCTestCase {
    [...]
    
    func testRemoteError() {
        let mockRemoteDataFetch = MockRemoteDataFetch()
        mockRemoteDataFetch.dataFromURLOverride = { url in
            throw NSError(domain: NSURLErrorDomain, code: URLError.Code.timedOut)
        }
        
        let imageCache = ImageCache(dependencies: GlobalDependencies.default.with(override: mockRemoteDataFetch, for: \.remoteDataFetch))
        
        // Then do stuff with that image cache.
        [...]
    }

    [...]
}

```

## Dependency Micropackages

In addition to the base GlobalDependencies package itself, we are building as needed a number of common system framework
façade dependencies that can be quickly and easily adopted to abstract away common hard dependencies and make the
resulting logic far more testable than otherwise.

These are mostly tiny so we call them depdendency micropackages (ok, the jokes write themselves). It's easy enough to
find those we built ourselves by just looking at the repo list for the account and checking those that are named
`*Dependency`.

Since those dependency micropackages are built up as needed by other projects they are usually not going to implement a
complete wrap of the abstracted API (unless all of it was needed at some point). Feel free to fork and expand if needed,
and please bring back a PR with any additions you make that may be useful to others.

## Requirements

GlobalDependencies doesn't have much in the way of dependencies itself so it can work in whatever the tools support.

### Tools:

* Xcode 14.3 or later.
* Swift 5.8 or later.

### Platforms:

* iOS 11 or later.
* macOS Catalyst 13 or later (but why?).
* macOS 10.13 or later.
* tvOS 11 or later.
* watchOS 4 or later.

## Installation

GlobalDependencies is currently only supported through Swift Package Manager.

If developing your own package, you can add the following lines to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Gabardone/GlobalDependencies", from: "2.0.0"),
]
```

To add to an Xcode project, paste `https://github.com/Gabardone/GlobalDependencies` into the URL field for a new package
and specify "Up to next major version" starting with the current one.

## Contributing

While the GlobalDependencies package itself works "as-is" and is unlikely to get major changes going forward, I know
better than to think it can't be improved, so suggestions are welcome especially if they come with examples.

The dependency micropackages can always use more work as they are built as needed. If you find yourself using one but
improving it, feel free to submit a PR with the changes. Same if you build a generic one for a system service that
other people could stand to use. I'll happily point to other people's dependency packages if anyone ends up creating
any.

Beyond that just take to heart the baseline rules presented in  [contributing guidelines](Contributing.md) prior to
submitting a Pull Request.

Thanks, and happy low friction dependency injection!

## Developing

Double-click on `Package.swift` in the root of the repository to open the project in Xcode. Or open the containing
folder from Xcode (from the command line: `open -a Xcode <path to package folder>` works as well).

## How to Use GlobalDependencies

A complete how-to can be found in `Dependencies.swift`
