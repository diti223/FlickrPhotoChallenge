//
//  PhotoChallengeTests.swift
//  PhotoChallengeTests
//
//  Created by Adrian Bilescu on 12.05.2022.
//

import XCTest
@testable import PhotoChallenge

class PhotoChallengeIntegrationTests: XCTestCase {

    func testSuccessfulFetch() async throws {
        let fetcher = FlickPhotoFetcher()
        
        let photos = try await fetcher.fetch("cats", page: 2, itemsCount: 50)
        
        XCTAssertTrue(!photos.isEmpty)
    }

}
