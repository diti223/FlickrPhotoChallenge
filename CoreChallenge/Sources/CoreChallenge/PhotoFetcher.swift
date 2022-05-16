//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 12.05.2022.
//

import Foundation

public protocol PhotoFetcher {
    func fetch(_ searchTerm: String, page: Int, itemsCount: Int) async throws -> [Photo]
}
