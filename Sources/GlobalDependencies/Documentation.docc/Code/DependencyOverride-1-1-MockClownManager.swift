@testable import ClownManagerDependency
import XCTest

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
