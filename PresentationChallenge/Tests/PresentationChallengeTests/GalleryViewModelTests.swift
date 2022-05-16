//
//  GalleryViewModelTests.swift
//  
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import XCTest
import PresentationChallenge
import CoreChallenge
import Combine

class GalleryViewModelTests: XCTestCase {
    var subscribers: Set<AnyCancellable> = []

    func testOnInit_NotFetching() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.isFetching, false)
    }
    
    func testOnInit_SearchTextIsEmpty() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.searchText, "")
    }
    
    func testOnInit_FetchedPhotosListIsEmpty() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.photos, [])
    }
    
    func testOnFetch_TogglesFetchingFlag() async {
        let (sut, _) = makeSUT()
        
        var isFetchingMessages: [Bool] = []
        sut.$isFetching.sink { isFetching in
            isFetchingMessages.append(isFetching)
        }.store(in: &subscribers)
        
        await sut.fetchPhotos()
        
        XCTAssertEqual([false, true, false], isFetchingMessages)
    }
    
    func testOnSearchTwoLettersWord_InvokesFetch() {
        let expectation = XCTestExpectation(description: "Fetch Photos")
        let (sut, client) = makeSUT()
        
        sut.searchText = "ab"
        client.invokedFetch = {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.1)
    }
    
    func testOnSearchOneLettersWord_DoesNotInvokeFetch() {
        let expectation = XCTestExpectation(description: "Fetch Photos")
        let (sut, client) = makeSUT()
        
        sut.searchText = "a"
        client.invokedFetch = {
            XCTFail("Shouldn't invoke fetch when search text is empty or one letter long")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    
    func testOnSearchDuplicatedSearchTextInvokesFetchOnce() {
        // given
        let expectation = XCTestExpectation(description: "Fetch Photos")
        let (sut, client) = makeSUT()
        
        // expected
        var invokedFetchesCount = 0
        client.invokedFetch = {
            invokedFetchesCount += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertEqual(invokedFetchesCount, 1)
            expectation.fulfill()
        }
        
        // when
        sut.searchText = "a"
        sut.searchText = "ab"
        sut.searchText = "ab"
        sut.searchText = "abc"
        sut.searchText = "ab"
        
        wait(for: [expectation], timeout: 1.1)
    }
    
    func testOnDidLoadAfterMiddlePhoto_InvokesFetch() async {
        // given
        let expectation = XCTestExpectation(description: "Fetch Photos")
        let (sut, client) = makeSUT()
        let photos = [anyPhoto(), anyPhoto(), anyPhoto()]
        client.stubPhotos = photos
        await sut.fetchPhotos()
        
        // expected
        client.invokedFetch = {
            expectation.fulfill()
        }
        
        // when
        sut.didLoad(photo: photos[2])
        
        wait(for: [expectation], timeout: 1.1)
    }
    
    func testOnDidLoadPhotoBeforeMiddle_DoesNotInvokeFetch() {
        // given
        let expectation = XCTestExpectation(description: "Fetch Photos")
        let (sut, client) = makeSUT()
        
        // expected
        client.invokedFetch = {
            XCTFail("Shouldn't invoke fetch when search text is empty or one letter long")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            expectation.fulfill()
        }
        
        // when
        let photos = [anyPhoto(), anyPhoto(), anyPhoto()]
        sut.didLoad(photo: photos[0])
        
        wait(for: [expectation], timeout: 5)
        
    }
    
    func testOnFetch_InvokesFetchSearchTermAndPageAndItemsCount40() async throws {
        let (sut, client) = makeSUT()
        
        await sut.fetchPhotos()
        
        XCTAssertEqual(client.invokedMessages, [PhotoFetcherStub.Message(searchTerm: "", page: 1, itemsCount: 40)])
    }
    
    
    
    private func makeSUT() -> (sut: GalleryViewModel, client: PhotoFetcherStub) {
        let fetcher = PhotoFetcherStub()
        let sut = GalleryViewModel(fetcher: fetcher)
        
        return (sut, fetcher)
    }

}

func anyPhoto() -> Photo {
    Photo(id: UUID().uuidString, url: anyURL())
}

func anyURL() -> URL {
    URL(string: "https://www.some-url.com/")!
}

class PhotoFetcherStub: PhotoFetcher {
    struct Message: Equatable {
        let searchTerm: String
        let page : Int
        let itemsCount: Int
    }
    
    var invokedMessages: [Message] = []
    var stubPhotos: [Photo] = []
    var invokedFetch: (() -> Void)?
    
    func fetch(_ searchTerm: String, page: Int, itemsCount: Int) async throws -> [Photo] {
        invokedMessages.append(Message(searchTerm: searchTerm, page: page, itemsCount: itemsCount))
        invokedFetch?()
        return stubPhotos
    }
}
