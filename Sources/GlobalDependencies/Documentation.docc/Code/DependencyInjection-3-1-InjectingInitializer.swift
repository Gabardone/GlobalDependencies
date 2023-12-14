@InjectedDependencies(dependencyAccess: .internal, ClownManager, HONKDevice)
class BirthdayParty {
    /**
     Initializes a birthday party
     - Parameters
       - celebrated The person who has made another revolution around the Sun.
       - date Date when the birthday happens
       - dependencies Injected dependencies
     */
    init(celebrated: Person, date: Date, dependencies: Dependencies) {
        self.dependencies = dependencies
        self.celebrated = celebrated
        self.date = date

        // Assume more useful code here.
    }

    // An unforgettable event happens here.
}
