//
//  LocationManager.swift
//  MiniDePin
//
//  Created by Óscar Morales Vivó on 5/20/23.
//

import Combine
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

public extension LocationManager {
    static var ErrorDomain: String {
        "GoogleAPIErrorDomain"
    }

    /**
     Verifies whether the user allows the calling app to access location.

     Call before any use of the location manager to verify that location can be accessed and let the system request
     user permission if it makes sense to do so.

     The method will throw if the user explicitly denied the application permission or it can't be otherwise obtained,
     i.e. if the device runs on a profile that disallows it.
     */
    func verifyUserPermissionToAccessLocation() async throws {
        switch authorizationStatus.value {
        case .authorizedAlways, .authorizedWhenInUse:
            // We're good to get the location.
            break

        case .notDetermined:
            // Present user UI.
            let _: Void = await withCheckedContinuation { continuation in
                var subscription: AnyCancellable?
                subscription = authorizationStatus.updates.sink { _ in
                    subscription?.cancel()
                    continuation.resume()
                }
                requestWhenInUseAuthorization()
            }

            // Once we land here the auth status has changed, so let's try again.
            try await verifyUserPermissionToAccessLocation()

        case .denied, .restricted:
            // Seeing weird behavior with custom error types so throwing an NSError instead. Needs further research.
            let localizedDescription = errorMessageForCLAuthStatus(
                authStatus: authorizationStatus.value
            )
            throw NSError(
                domain: Self.ErrorDomain,
                code: 7777,
                userInfo: [NSLocalizedDescriptionKey: localizedDescription]
            )

        @unknown default:
            // Seeing weird behavior with custom error types so throwing an NSError instead. Needs further research.
            let localizedDescription = errorMessageForCLAuthStatus(
                authStatus: authorizationStatus.value
            )
            throw NSError(
                domain: Self.ErrorDomain,
                code: 7777,
                userInfo: [NSLocalizedDescriptionKey: localizedDescription]
            )
        }
    }

    func obtainCurrentLocation() async throws -> CLLocation {
        if case let .located(currentLocation) = currentLocation.value {
            // No matter what make sure we'll be updating the location.
            startUpdatingLocation()
            return currentLocation
        } else {
            // Wait for the delegate to get called (or fail) and then continue that.
            return try await withCheckedThrowingContinuation { continuation in
                var subscription: AnyCancellable?
                subscription = currentLocation.updates.sink { trackedLocation in
                    switch trackedLocation {
                    case let .located(currentLocation):
                        subscription?.cancel()
                        continuation.resume(returning: currentLocation)

                    case let .failure(error):
                        subscription?.cancel()
                        continuation.resume(throwing: error)

                    case .unknown:
                        // Just going to keep waiting for something more informative to come up.
                        break
                    }
                }
                startUpdatingLocation()
            }
        }
    }

    private func errorMessageForCLAuthStatus(authStatus: CLAuthorizationStatus) -> String {
        switch authStatus {
        case .denied:
            if CLLocationManager.locationServicesEnabled() {
                return "Please go to settings and authorize the application to access the current location."
            } else {
                return """
                Please reenable location services in settings and authorize the application to obtain the device \
                location.
                """
            }

        case .restricted:
            return """
             LunchQuest cannot use location services. Please contact your device's administrator to authorize \
             the app to do so.
            """

        default:
            return "Unable to obtain the user's location for mysterious reasons."
        }
    }
}
