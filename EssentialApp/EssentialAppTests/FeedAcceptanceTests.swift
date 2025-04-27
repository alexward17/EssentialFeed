import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(makeSuccessfulResponse))
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysCachedFeedWhenUserHasNoConnectivity() {
        let sharedStore = InMemoryStore.empty
        let onlineFeed = launch(httpClient: .online(makeSuccessfulResponse), store: sharedStore)

        onlineFeed.simulateImageVisible(at: 0)
        onlineFeed.simulateImageVisible(at: 1)

        let offlineFeed = launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityandNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }

    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryStore.withExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }

    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryStore.withNonExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }

    // MARK: - Helpers

    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryStore = .empty
    ) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }

    private func enterBackground(with store: InMemoryStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)

        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private class HTTPClientStub: HTTPClient {

        private class Task: HTTPClientTask { func cancel(){} }

        private let stub: (URL) -> HTTPClient.Result

        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any EssentialFeed.HTTPClientTask {
            completion(stub(url))
            return Task()
        }

        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }

        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }

    }

    private class InMemoryStore: FeedStore, FeedImageDataStore {

        var feedCache: CachedFeed?
        var feedImageDataCache = [URL: Data]()

        public init(feedCache: CachedFeed? = nil) {
            self.feedCache = feedCache
        }

        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            feedCache = nil
            completion(.success(Void()))
        }
        
        func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            feedCache = CachedFeed(feed, timestamp: timestamp)
            completion(.success(Void()))
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            completion(.success(feedCache))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            feedImageDataCache = [url: data]
            completion(.success(Void()))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }

        static var empty: InMemoryStore {
            InMemoryStore()
        }

        static var withExpiredFeedCache: InMemoryStore {
            InMemoryStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
        }

        static var withNonExpiredFeedCache: InMemoryStore {
            InMemoryStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
        }

    }

    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()

        default:
            return makeFeedData()
        }
    }

    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }

}

