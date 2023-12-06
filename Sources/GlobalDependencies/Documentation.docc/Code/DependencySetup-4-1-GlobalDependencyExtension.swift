@Dependency
protocol ClownManager {
    func honk()

    func slap()

    func pie(flavor: PieFilling)

    var shoeSize: Double { get set }

    // And more...
}

// Default Dependency Value Factory

private struct DefaultClownManagerValueFactory: DefaultDependencyValueFactory {
    static func makeDefaultValue() -> any ClownManager {
        #if DEBUG
        return PagliacciClownManager(FakePagliacci())
        #else
        return PagliacciClownManager(RealPagliacci())
        #endif
    }
}

// GlobalDependencies Integration

extension GlobalDependencies: ClownManager.Dependency {
    #GlobalDependency(type: ClownManager)
}
