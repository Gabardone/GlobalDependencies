//
//  NetworkDependency.swift
//
//
//  Created by Óscar Morales Vivó on 5/28/23.
//

import Foundation
import MiniDePin

/**
 A protocol to adopt for dependencies that require access to the network.
 */
public protocol NetworkDependency: Dependencies {
    var network: any Network { get }
}

extension GlobalDependencies: NetworkDependency {
    private static let defaultNetwork: any Network = SystemNetwork()

    public var network: any Network {
        resolveDependency(forKeyPath: \.network, defaultImplementation: Self.defaultNetwork)
    }
}
