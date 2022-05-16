import XCTest
import FlickrChallenge
import CoreChallenge

final class FlickrFetcherTests: XCTestCase {
    func testOnFetch_URLFormat() async throws {
        let (sut, client) = makeSUT()
        
        _ = try? await sut.fetch("cats", page: 2, itemsCount: 50)
        let components = URLComponents(url: client.urlMessages[0], resolvingAgainstBaseURL: true)!
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "api.flickr.com")
        XCTAssertEqual(components.path, "/services/rest/")
        
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "method", value: "flickr.photos.search")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "text", value: "cats")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "api_key", value: "ab4f8e24a6c57af09558cf252c105ae7")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "format", value: "json")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "per_page", value: "\(50)")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "page", value: "\(2)")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "nojsoncallback", value: "1")))
        
        XCTAssertEqual(client.urlMessages.count, 1)
        XCTAssertEqual(client.urlMessages, [URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&text=cats&api_key=ab4f8e24a6c57af09558cf252c105ae7&format=json&per_page=50&page=2&nojsoncallback=1")!])
    }
    
    func testReceivingInvalidJSON_ThrowsDecodingError() async {
        let (sut, _) = makeSUT(stub: .success("invalid_data".data(using: .utf8)!, any200URLResponse()))
        
        do {
            _ = try await sut.fetch("some search term", page: 1, itemsCount: 20)
            XCTFail("Should throw decoding error")
        } catch {
            XCTAssertTrue(error as! FlickrFetcher.Error == FlickrFetcher.Error.decodingError)
        }
    }
    
    func testReceivingValidPhotosJSONOnInvalidStatusCode_ThrowsInvalidStatusCodeError() throws {
        let (_, json) = makePhoto(id: "some-id", ownerId: "owner-id", title: "Hello Title", secret: "some secret", serverId: "1324", farmId: 1324)
        
        let invalidCodes = [100, 101, 199, 201, 400, 404, 500]
        
        var expectations: [XCTestExpectation] = []
        
        invalidCodes.forEach { invalidCode in
            let expectation = self.expectation(description: "Expected throwing invalid status code \(invalidCode)")
            expectations.append(expectation)
            Task {
                let data = try! JSONSerialization.data(withJSONObject: json)
                let (sut, _) = makeSUT(stub: .success(data, makeURLResponse(code: invalidCode)))
                do {
                    _ = try await sut.fetch("something")
                    XCTFail("Expected to throw error for status code \(invalidCode)")
                } catch {
                    switch error {
                        case HTTPClientError.invalidStatusCode(let code):
                            XCTAssertEqual(code, invalidCode)
                            expectation.fulfill()
                        default:
                            XCTFail("Expected invalid status code error")
                    }
                }
            }
        }
        
        wait(for: expectations, timeout: 0.1)
    }
    
    func testReceivingValidPhotosJSONOnStatusCode200() async throws {
        
        let (model, photoJSON) = makePhoto(id: "some-id", ownerId: "owner-id", title: "Hello Title", secret: "some secret", serverId: "1324", farmId: 1324)
        let resultJSON = makeSearchResultJSON(photos: [photoJSON])
        
        
        let (sut, _) = makeSUT(stub: .success(try! JSONSerialization.data(withJSONObject: resultJSON), any200URLResponse()))
        
        let result = try await sut.fetch("something")
        
        XCTAssertEqual(result, [model])
    }
        
    private func makeSUT(stub: HTTPClientStub.Result = .success(anyData(), anyURLResponse())) -> (FlickrFetcher, HTTPClientStub) {
        let client = HTTPClientStub(stub: stub)
        let sut = FlickrFetcher(httpClient: client)
        
        return (sut, client)
    }
    
    private func makeSearchResultJSON(page: Int = 1, pages: Int = 1, perPage: Int = 20, total: Int = 100, photos: [[String: Any]]) -> [String: Any] {
        
        ["photos": ["page": page, "pages": pages, "perpage": perPage, "total": total, "photo": photos]]
    }
    
    private func makePhoto(id: String, ownerId: String, title: String, secret: String, serverId: String, farmId: Int) -> (model: Photo, json: [String: Any]) {
        
        let json: [String: Any] = ["id": id, "owner": ownerId, "title": title, "secret": secret, "server": serverId, "farm": farmId]
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "farm\(farmId).staticflickr.com"
        components.path = "/\(serverId)/\(id)_\(secret)_c.jpg"
        
        let model = Photo(id: id, url: components.url!)
        
        return (model, json)
    }
    
}

func anyData() -> Data {
    "some data".data(using: .utf8)!
}

func anyURLResponse() -> HTTPURLResponse {
    makeURLResponse(code: -1)
}

func makeURLResponse(code: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
}
                                                   
func any200URLResponse() -> HTTPURLResponse {
    makeURLResponse(code: 200)
}

func anyURL() -> URL {
    URL(string: "www.anyURL.com")!
}


class HTTPClientStub: HTTPClient {
    init(stub: HTTPClientStub.Result) {
        self.stub = stub
    }
    
    enum Result {
        case success(Data, HTTPURLResponse)
        case failure(HTTPClientError)
    }
    
    var urlMessages: [URL] = []

    let stub: Result
    func data(from url: URL) throws -> (Data, HTTPURLResponse) {
        urlMessages.append(url)
        switch stub {
            case .success(let data, let urlResponse):
                return (data, urlResponse)
            case .failure(let error):
                throw error
        }
    }
}
