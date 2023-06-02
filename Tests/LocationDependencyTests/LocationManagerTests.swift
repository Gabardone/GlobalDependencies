//
//  LocationManagerTests.swift
//
//
//  Created by Óscar Morales Vivó on 6/1/23.
//

import CoreLocation
import LocationDependency
@testable import LocationDependencyTesting
import SwiftUX
import XCTest

/**
 Tests the common location manager flows.
 */
final class LocationManagerTests: XCTestCase {
    func testObtainCurrentLocationHappyPath() async throws {
        let mockLocationManager = MockLocationManager()
        mockLocationManager.authorizationStatus = WritableProperty.root(initialValue: .authorizedAlways)

        let expectedlocation = CLLocation(latitude: 37.27661, longitude: -122.19913) // You should go there.
        let locationProperty: WritableProperty<TrackedLocation> = .root(initialValue: .unknown)
        mockLocationManager.currentLocation = locationProperty

        let startUpdatingExpectation = expectation(description: "Called `startUpdatingLocation`")
        mockLocationManager.startUpdatingLocationOverride = {
            startUpdatingExpectation.fulfill()
            Task {
                locationProperty.value = .located(expectedlocation)
            }
        }

        let resultingLocation = try await mockLocationManager.obtainCurrentLocation()

        await fulfillment(of: [startUpdatingExpectation])

        XCTAssertEqual(resultingLocation, expectedlocation)
    }

    func testObtainCurrentLocationSadPath() async throws {
        let mockLocationManager = MockLocationManager()
        mockLocationManager.authorizationStatus = WritableProperty.root(initialValue: .authorizedAlways)

        let locationProperty: WritableProperty<TrackedLocation> = .root(initialValue: .unknown)
        mockLocationManager.currentLocation = locationProperty

        let startUpdatingExpectation = expectation(description: "Called `startUpdatingLocation`")
        mockLocationManager.startUpdatingLocationOverride = {
            startUpdatingExpectation.fulfill()
            Task {
                locationProperty.value = .failure(MockLocationManager.MockError.mock)
            }
        }

        do {
            _ = try await mockLocationManager.obtainCurrentLocation()
            XCTFail("Unexpectedly succeeded at getting the current location")
        } catch MockLocationManager.MockError.mock {
            // This statement intentionally left blank.
        } catch {
            XCTFail("Unexpected error found \(String(describing: error))")
        }

        await fulfillment(of: [startUpdatingExpectation])
    }
}
