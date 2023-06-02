//
//  MockLocationManager.swift
//
//
//  Created by Óscar Morales Vivó on 5/27/23.
//

import Combine
import CoreLocation
import Foundation
import LocationDependency
import SwiftUX
import XCTest

/**
 A mock implementation of `LocationManager`.

 Override the stored properties or the override blocks to get the behavior you need for your test.

 Everything is declared `open` for maximum flexibility in test setups, but setting the properties should work for the
 vast majority of cases.
 */
open class MockLocationManager: LocationManager {
    public enum MockError: Error {
        /**
         Throw this when the error is due to the mock setup not matching the test behavior.
         */
        case unexpectedCall(String)

        /**
         Throw this in tests when a thrown error is expected
         */
        case mock
    }

    // MARK: - LocationManager Adoption

    open var authorizationStatus: any Property<CLAuthorizationStatus> = ReadOnlyProperty(updates: Empty()) {
        mockFailure()
        return .notDetermined
    }

    open var currentLocation: any Property<TrackedLocation> = ReadOnlyProperty(updates: Empty()) {
        mockFailure()
        return .failure(MockError.unexpectedCall(#function))
    }

    open var requestWhenInUseAuthorizationOverride: (() -> Void)?

    open func requestWhenInUseAuthorization() {
        if let requestWhenInUseAuthorizationOverride {
            requestWhenInUseAuthorizationOverride()
        } else {
            Self.mockFailure()
        }
    }

    open var startUpdatingLocationOverride: (() -> Void)?

    open func startUpdatingLocation() {
        if let startUpdatingLocationOverride {
            startUpdatingLocationOverride()
        } else {
            Self.mockFailure()
        }
    }

    open var stopUpdatingLocationOverride: (() -> Void)?

    open func stopUpdatingLocation() {
        if let stopUpdatingLocationOverride {
            stopUpdatingLocationOverride()
        } else {
            Self.mockFailure()
        }
    }

    // MARK: - Utilities

    public static func mockFailure(function: String = #function) {
        XCTFail("Unexpected call to \(function)")
    }
}
