//
//  LocationManager.swift
//  MiniDePin
//
//  Created by Óscar Morales Vivó on 5/20/23.
//

import CoreLocation
import Foundation
import SwiftUX

public enum TrackedLocation {
    /**
     The current location remains unknown. Either it has not been requested yet or it has not been returned yet.

     If the location manager requests the location and the operation fails you will see `failure(error)` instead.
     */
    case unknown

    /**
     The location has been found, the associated value is the last update.
     */
    case located(CLLocation)

    /**
     There was a failure obtaining the location. The associated value is the proximate error that caused the failure.
     */
    case failure(Error)
}

extension TrackedLocation: Equatable {
    /**
     To avoid redundant calls to subscribers of our tracked location we implement `Equatable` on the type even if it
     can't be done so perfectly (`.failure` cases cannot be reliably compared).

     Getting the same error more than once should still cause a subscriber update so this implementation still serves
     our needs well.
     */
    public static func == (lhs: TrackedLocation, rhs: TrackedLocation) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true

        case let (.located(lhsLocation), .located(rhsLocation)):
            return lhsLocation == rhsLocation

        default:
            return false
        }
    }
}

/**
 A façade protocol for the system's location manager.

 As it exists, `CLLocationManager` introduces a hard dependency that gets in the way of making location-using logic
 testable. This protocol is used to wrap the parts of its functionality needed by the app, while allowing for an easy
 build of a testing mock.
 */
public protocol LocationManager {
    /**
     A `Property` that manages the current authorization status and publishes its updates.
     */
    var authorizationStatus: any Property<CLAuthorizationStatus> { get }

    /**
     A `Property` that manages the last returned device location. May be `nil` if it is unavailable so far.
     */
    var currentLocation: any Property<TrackedLocation> { get }

    /**
     Façade for the `CLLocationManager` API of the same name.
     */
    func requestWhenInUseAuthorization()

    /**
     Façade for the `CLLocationManager` API of the same name.
     */
    func startUpdatingLocation()

    /**
     Façade for the `CLLocationManager` API of the same name.
     */
    func stopUpdatingLocation()
}
