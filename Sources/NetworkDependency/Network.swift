//
//  Network.swift
//  MiniDepIn
//
//  Created by Óscar Morales Vivó on 1/16/23.
//

import Foundation
import MiniDePin

/**
 A protocol that abstracts away network operations.

 So far the only one we've needed abstracting is fetching data from a URL.
 */
public protocol Network {
    /**
     Returns a task that asynchronously fetches data from the given URL, or throws otherwise.
     - Parameter url: The url pointing to the data we want to fetch.
     - Returns: A `Task` that can be awaited for the data or which will `throw` if there is an error fetching it.
     */
    func dataTask(url: URL) -> Task<Data, Error>
}
