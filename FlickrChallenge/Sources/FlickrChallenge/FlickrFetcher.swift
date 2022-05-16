//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 15.05.2022.
//

import Foundation
import CoreChallenge

public class FlickrFetcher: PhotoFetcher {
    public enum Error: Swift.Error {
        case decodingError
    }
    
    let httpClient: HTTPClient
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func fetch(_ searchTerm: String, page: Int = 1, itemsCount: Int = 20) async throws -> [Photo] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/"
        components.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "text", value: searchTerm),
            URLQueryItem(name: "api_key", value: FlickrAPI.key),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "per_page", value: "\(itemsCount)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        
        
        let (data, response) = try await httpClient.data(from: components.url!)
        guard response.statusCode == 200 else {
            throw HTTPClientError.invalidStatusCode(response.statusCode)
        }
        
        let jsonDecoder = JSONDecoder()
        guard let result = try? jsonDecoder.decode(FlickrSearchResult.self, from: data) else {
            throw Error.decodingError
        }
        
        
        return result.photos.photo.compactMap { (flickrPhoto) -> Photo? in
            let photoURL = PhotoURL(serverId: flickrPhoto.serverId, farmId: flickrPhoto.farmId, id: flickrPhoto.id, secret: flickrPhoto.secret)
            guard let url = photoURL.urlComponents.url else {
                return nil
            }
            return Photo(id: flickrPhoto.id, url: url)
        }
    }
}
