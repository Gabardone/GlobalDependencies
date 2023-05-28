//
//  SystemLocationManager.swift
//
//
//  Created by Óscar Morales Vivó on 5/27/23.
//

import Combine
import CoreLocation
import Foundation
import SwiftUX

/**
 A wrapper for the system's location manager.

 While basic access and request methods of `CLLocationManager` doesn't need wrapping, the delegate methods are harder
 to façade properly. Since almost all `CLLocationManagerDelegate` methods are purely reactive and the one that isn't we
 don't need, we reduce the dependency surface of the protocol façade by translating the delegate methods into combine
 subscriptions.

 All of the interaction with our private `CLLocationManager` instance is redirected to the main thread since the class
 only works with an active runloop on whichever thread it is initialized and setting up a custom one isn't worth it.
 Thankfully all operations of `LocationManager` are unidirectional so the asynchronous setup shouldn't be a problem.
 */
class SystemLocationManager: NSObject {
    override init() {
        self.authorizationStatusSubject = .init(.notDetermined)
        self.authorizationStatusProperty = .init(
            updates: authorizationStatusSubject.removeDuplicates().dropFirst(),
            getter: { [authorizationStatusSubject] in
                authorizationStatusSubject.value
            }
        )
        self.currentLocationProperty = .init(
            updates: currentLocationSubject.removeDuplicates().dropFirst(),
            getter: { [currentLocationSubject] in
                currentLocationSubject.value
            }
        )

        super.init()

        DispatchQueue.main.async {
            let locationManager = CLLocationManager()
            self.locationManager = locationManager
            locationManager.delegate = self
        }
    }

    private let runLoop = RunLoop.current

    private var locationManager: CLLocationManager?

    private let authorizationStatusSubject: CurrentValueSubject<CLAuthorizationStatus, Never>

    private let authorizationStatusProperty: ReadOnlyProperty<CLAuthorizationStatus>

    private let currentLocationSubject = CurrentValueSubject<TrackedLocation, Never>(.unknown)

    private let currentLocationProperty: ReadOnlyProperty<TrackedLocation>
}

// MARK: - LocationManager Adoption

extension SystemLocationManager: LocationManager {
    var authorizationStatus: any Property<CLAuthorizationStatus> {
        authorizationStatusProperty
    }

    var currentLocation: any Property<TrackedLocation> {
        currentLocationProperty
    }

    func requestWhenInUseAuthorization() {
        DispatchQueue.main.async {
            self.locationManager?.requestWhenInUseAuthorization()
        }
    }

    func startUpdatingLocation() {
        DispatchQueue.main.async {
            self.locationManager?.startUpdatingLocation()
        }
    }

    func stopUpdatingLocation() {
        DispatchQueue.main.async {
            self.locationManager?.stopUpdatingLocation()
        }
    }
}

// MARK: - Private CLLocationManagerDelegate Adoption.

extension SystemLocationManager: CLLocationManagerDelegate {
    @MainActor
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        assert(
            manager == locationManager,
            "`CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:)` from unexpected object \(manager)"
        )

        // Update the storage.
        authorizationStatusSubject.send(manager.authorizationStatus)
    }

    @MainActor
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        assert(
            manager == locationManager,
            "`CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)` from unexpected object \(manager)"
        )

        // Update the current location.
        guard let lastLocation = locations.last else {
            return
        }

        currentLocationSubject.send(.located(lastLocation))
    }

    @MainActor
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard manager === locationManager else {
            fatalError()
        }

        currentLocationSubject.send(.failure(error))
    }
}
