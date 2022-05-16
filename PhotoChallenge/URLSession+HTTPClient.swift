//
//  URLSession+HTTPClient.swift
//  PhotoChallenge
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import Foundation
import CoreChallenge

extension URLSession: HTTPClient {
    public func data(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await data(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }
        return (data, httpResponse)
    }
}
