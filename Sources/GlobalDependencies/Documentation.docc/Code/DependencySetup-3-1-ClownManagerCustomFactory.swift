@Dependency(defaultValueFactory: PagliacciClownManager)
protocol ClownManager {
    func honk()

    func slap()

    func pie(flavor: PieFilling)

    var shoeSize: Double { get set }

    // And more...

    // Generated by the @Dependency macro

    typealias Dependency = ClownManagerDependency

    typealias DependencyKey = ClownManagerDependencyKey
}

// Generated by the @Dependency macro

protocol ClownManagerDependency: Dependencies {
    var clownManager: any ClownManager { get }
}

struct ClownManagerDependencyKey: DependencyKey {
    static let defaultValue: any ClownManager = PagliacciClownManager.makeDefaultValue()
}

// Default Dependency Value Factory

private extension PagliacciClownManager: DefaultDependencyValueFactory {
    static func makeDefaultValue() -> any ClownManager {
        #if DEBUG
        return PagliacciClownManager(FakePagliacci())
        #else
        return PagliacciClownManager(RealPagliacci())
        #endif
    }
}
