//
//  MockNetwork.swift
//
//
//  Created by Óscar Morales Vivó on 5/28/23.
//

import Foundation

/**
 Simple mock for network data access. Use it in tests as an override of `NetworkDependency`.

 This should go into its own package but that causes issues where the compiler gets confused in test targets and
 dependency overrides fail to work.
  */
public struct MockNetwork {
    public init(dataTaskOverride: ((URL) -> Task<Data, Error>)? = nil) {
        self.dataTaskOverride = dataTaskOverride
    }

    /**
     Throw this when the error is due to the mock setup not matching the test behavior.
     */
    public enum MockError: Error {
        case unexpectedCall(String)
    }

    var dataTaskOverride: ((URL) -> Task<Data, Error>)?
}

extension MockNetwork: Network {
    public func dataTask(url: URL) -> Task<Data, Error> {
        if let dataTaskOverride {
            return dataTaskOverride(url)
        } else {
            return Task {
                throw MockError.unexpectedCall(#function)
            }
        }
    }
}
