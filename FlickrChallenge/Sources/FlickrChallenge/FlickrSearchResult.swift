//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import Foundation

struct FlickrSearchResult: Decodable {
    let photos: FlickrPhotoPage
}

struct FlickrPhotoPage: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner"
        case title = "title"
        case secret
        case serverId = "server"
        case farmId = "farm"
        
    }
    let id: String
    let ownerId: String
    let title: String
    let secret: String
    let serverId: String
    let farmId: Int
}
