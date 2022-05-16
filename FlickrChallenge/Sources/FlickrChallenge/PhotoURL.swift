//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import Foundation
import CoreChallenge

struct PhotoURL {
    let serverId: String
    let farmId: Int
    let id: String
    let secret: String
    var size: PhotoSize? = .medium
    
    
    /// how to create Photo image URLs: https://www.flickr.com/services/api/misc.urls.html
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "farm\(farmId).staticflickr.com"
        var path = "/\(serverId)/\(id)_\(secret)"
        if let size = size {
            path.append("_\(size.suffix)")
        }
        path.append(".jpg")
        components.path = path
        return components
    }
}
