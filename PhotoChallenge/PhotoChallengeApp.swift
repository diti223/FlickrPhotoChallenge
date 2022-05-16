//
//  PhotoChallengeApp.swift
//  PhotoChallenge
//
//  Created by Adrian Bilescu on 12.05.2022.
//

import SwiftUI
import PresentationChallenge
import FlickrChallenge

@main
struct PhotoChallengeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: GalleryViewModel(fetcher: FlickrFetcher(httpClient: URLSession.shared)))
        }
    }
}

