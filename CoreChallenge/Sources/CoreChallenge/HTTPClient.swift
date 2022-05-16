//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import Foundation

public protocol HTTPClient {
    func data(from url: URL) async throws -> (Data, HTTPURLResponse)
}

