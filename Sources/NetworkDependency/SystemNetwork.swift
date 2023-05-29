//
//  SystemNetwork.swift
//  MiniDepIn
//
//  Created by Óscar Morales Vivó on 3/29/23.
//

import Foundation

/**
 An implementation of the `Network` protocol that uses the system facilities, namely `URLSession.shared` to fetch data.
 */
struct SystemNetwork {}

extension SystemNetwork: Network {
    func dataTask(url: URL) -> Task<Data, Error> {
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    }
}
