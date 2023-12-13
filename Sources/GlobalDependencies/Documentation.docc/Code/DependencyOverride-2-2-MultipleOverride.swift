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

    func testClownIntroHonksAndSlaps() {
        var mockClownManager = MockClownManager()
        let slapExpectation = expectation("Clown slaps")
        mockClownManager.slapOverride = {
            slapExpectation.fulfill()
        }

        var mockHONKDevice = MockHONKDevice()
        let honkExpectation = expectation("HONK")
        mockHONKDevice.honkOverride = { times in
            XCTAssertEqual(times, 1)
            honkExpectation.fulfill()
        }

        var mockDependencies = GlobalDependencies.default
        mockDependencies.override(key: ClownManager.DependencyKey, with: mockClownManager)
        mockDependencies.override(key: HONKDevice.DependencyKey, with: mockHONKDevice)

        let birthdayParty = BirthdayParty(celebrated: .mock, date: .mock, dependencies: mockDependencies)
        birthdayParty.introduceClown()

        wait(for: [slapExpectation, honkExpectation])
    }

    // Assume there's more stuff in this class...
}

struct MockHONKDevice: HONKDevice {
    var honkOverride: ((Int) -> Void)?

    func honk(times: Int) {
        if let honkOverride {
            honkOverride(times)
        } else {
            XCTFail("mock \(#function) at \(#file) called with no override set")
        }
    }

    var hooooooonkOverride: (() -> Void)?

    func hooooooonk() {
        if let hooooooonkOverride {
            hooooooonkOverride()
        } else {
            XCTFail("mock \(#function) at \(#file) called with no override set")
        }
    }
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
