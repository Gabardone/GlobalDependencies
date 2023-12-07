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

    // You don't need to unit test this one as it already involves enough mocking.

    func introduceClown() {
        let clownManager = dependencies.clownManager
        clownManager.honk()
        clownManager.slap(victim: celebrated)
    }

    // The high point of the party.

    func pieTime() {
        let pie = Pie(flavor: .strawberry)
        pie.present()

        // This makes perfect sense if you think about it.
        let pieRoulette = PieRoulette(pie, dependencies.buildGlobal())
        pieRoulette.start()
    }

    // Lots more fun code should be here.
}
