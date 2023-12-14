private extension PagliacciClownManager: DefaultDependencyValueFactory {
    static func makeDefaultValue() -> any ClownManager {
        #if DEBUG
        return PagliacciClownManager(FakePagliacci())
        #else
        return PagliacciClownManager(RealPagliacci())
        #endif
    }
}
