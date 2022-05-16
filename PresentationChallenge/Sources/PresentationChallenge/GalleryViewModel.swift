//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import Foundation
import Combine
import CoreChallenge

public class GalleryViewModel: ObservableObject {
    
    @Published public private(set) var photos: [Photo] = []
    @Published public var searchText = ""
    @Published public var isFetching = false
    
    private var subscribers: Set<AnyCancellable> = []
    private let itemsCount = 40
    private var page = 1
    private let fetcher: PhotoFetcher
    
    public init(fetcher: PhotoFetcher) {
        self.fetcher = fetcher
        
        $searchText
            .print()
            .drop(while: { $0.count <= 1 })
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.photos.removeAll()
                Task { [weak self] in
                    await self?.fetchPhotos()
                }
            }.store(in: &subscribers)
        
    }
    
    public func didLoad(photo: Photo) {
        let middleIndex = photos.endIndex - photos.endIndex/2
        guard let photoIndex = photos.firstIndex(of: photo) else {
            // did not
            return
        }
        let isPhotoAfterMiddle = photoIndex >= middleIndex
        
        if isPhotoAfterMiddle && !isFetching {
            page += 1
            Task {
                await fetchPhotos()
            }
        }
    }
    
    public func fetchPhotos() async {
        isFetching = true
        let photos = (try? await fetcher.fetch(searchText, page: page, itemsCount: itemsCount)) ?? []    
        isFetching = false
        self.photos.append(contentsOf: photos)
    }
}
