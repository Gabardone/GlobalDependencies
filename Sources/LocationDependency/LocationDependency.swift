//
//  LocationDependency.swift
//
//
//  Created by Óscar Morales Vivó on 5/27/23.
//

import Foundation
import MiniDePin

/**
 A protocol to adopt for dependencies that require access to a `LocationManager`.
 */
public protocol LocationDependency: Dependencies {
    var locationManager: any LocationManager { get }
}

extension GlobalDependencies: LocationDependency {
    private static let systemLocationManager: any LocationManager = SystemLocationManager()

    public var locationManager: any LocationManager {
        resolveDependency(forKeyPath: \.locationManager, defaultImplementation: Self.systemLocationManager)
    }
}
