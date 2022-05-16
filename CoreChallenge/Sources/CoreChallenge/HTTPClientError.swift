//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import Foundation

public enum HTTPClientError: Error {
    case invalidStatusCode(Int)
    case invalidResponse
}
