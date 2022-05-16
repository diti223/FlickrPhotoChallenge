//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 12.05.2022.
//

import Foundation

public struct Photo: Equatable {
    public let id: String
    public let url: URL

    public init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}
