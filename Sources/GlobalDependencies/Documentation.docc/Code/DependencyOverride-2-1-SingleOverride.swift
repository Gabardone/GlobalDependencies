import XCTest

class BirthdayPartyTests: XCTestCase {
    func testClownIntroSlapsCelebrant() {
        var mockClownManager = MockClownManager()
        let slapExpectation = expectation("Clown slaps")
        mockClownManager.slapOverride = {
            slapExpectation.fulfill()
        }
        let mockDependencies = GlobalDependencies.default.with(
            override: mockClownManager,
            for: ClownManager.DependencyKey
        )

        let birthdayParty = BirthdayParty(celebrated: .mock, date: .mock, dependencies: mockDependencies)
        birthdayParty.introduceClown()

        wait(for: [slapExpectation])
    }

    // Assume there's more stuff in this class...
}

struct MockClownManager: ClownManager {
    var honkOverride: (() -> Void)?

    func honk() {
        if let honkOverride {
            honkOverride()
        } else {
            XCTFail("mock \(#function) at \(#file) called with no override set")
        }
    }

    var slapOverride: ((Person) -> Void)?

    func slap(victim _: Person) {
        if let slapOverride {
            slapOverride(person)
        } else {
            XCTFail("mock \(#function) at \(#file) called with no override set")
        }
    }

    var pieToFaceOverride: ((Pie, Person) -> Void)?

    func pieToFace(pie: Pie, victim: Person) {
        if let pieToFaceOverride {
            pieToFaceOverride(pie, victim)
        } else {
            XCTFail("mock \(#function) at \(#file) called with no override set")
        }
    }

    var shoeSizeGetterOverride: (() -> Double)?

    var shoeSizeSetterOverride: ((Double) -> Void)?

    var shoeSize: Double {
        get {
            if let shoeSizeGetterOverride {
                shoeSizeGetterOverride()
            } else {
                XCTFail("mock \(#function) at \(#file) called with no override set")
                return 0.0
            }
        }

        set {
            if let shoeSizeSetterOverride {
                shoeSizeGetterOverride(newValue)
            } else {
                XCTFail("mock \(#function) at \(#file) called with no override set")
            }
        }
    }
}
