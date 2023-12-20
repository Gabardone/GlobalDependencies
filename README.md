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

As of version 2 and up, the package leans heavily on the use of Swift macros so support for Xcode 15 and the Swift 5.9
toolchain or newer are required.

## Requirements

GlobalDependencies doesn't have much in the way of dependencies itself so it can work in whatever the tools support.

### Tools:

* Xcode 15.1 or later.
* Swift 5.9 or later.

### Platforms:

* iOS 13 or later.
* macOS Catalyst 13 or later (but why?).
* macOS 10.15 or later.
* tvOS 13 or later.
* watchOS 6 or later.

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

## How to Use GlobalDependencies

The package is fully documented, including tutorials for expected use.

You can find an online version of the documentation at
https://gabardone.github.io/GlobalDependencies/documentation/globaldependencies/

When developing on Xcode with the dependency installed you can also select `Product -> Build Documentation` which will
add the package's documentation to the contents of the Xcode documentation viewer.

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
