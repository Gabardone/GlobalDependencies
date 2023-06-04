//
//  SystemNetwork.swift
//  MiniDepIn
//
//  Created by Óscar Morales Vivó on 3/29/23.
//

import Foundation

/**
 An implementation of the `Network` protocol that uses the system facilities, namely a `URLSession` instance, to fetch
 data.

 By default they are created using `URLSession.shared` but the option exists to use a different one.
 */
public struct SystemNetwork {
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    let urlSession: URLSession
}

extension SystemNetwork: Network {
    public func dataTask(url: URL) -> Task<Data, Error> {
        Task {
            let (data, _) = try await urlSession.data(from: url)
            return data
        }
    }
}
