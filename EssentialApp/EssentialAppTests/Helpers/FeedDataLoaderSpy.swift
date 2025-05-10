import EssentialFeed
import XCTest

class FeedDataLoaderSpy: FeedImageDataLoader {

    // MARK: - Feed Loader Properties

    final var loadFeedCallCount: Int {
        feedRequests.count
    }

    private var feedRequests: [( Swift.Result<[FeedImage], Error>) -> Void] = []

    // MARK: - Feed Loader Helper Functions

    func load(completion: @escaping ( Swift.Result<[FeedImage], Error>) -> Void) {
        feedRequests.append(completion)
    }

    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = .zero) {
        feedRequests[index](.success(feed))
    }

    func completeFeedLoadingWithError(at index: Int = .zero) {
        feedRequests[index](.failure(XCTestCase.anyError))
    }

    // MARK: - Feed Image Data Loader Properties

    var loadedImageURLs: [URL?] {
        imageRequests.map({ $0.url })
    }

    private(set) var cancelledImageURLs = [URL?]()
    private var imageRequests: [(url: URL?, completion: (FeedImageDataLoader.Result) -> Void)] = []

    // MARK: - Feed Image Data LoaderFunctions

    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallBack: () -> Void
        func cancel() {
            cancelCallBack()
        }
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy(cancelCallBack:  { [weak self] in
            self?.cancelledImageURLs.append(url)
        })
    }

    func cancelImageLoading(for url: URL) {
        cancelledImageURLs.append(url)
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = .zero) {
        imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = .zero) {
        imageRequests[index].completion(.failure(XCTestCase.anyError))
    }

}

public extension XCTestCase {
    func checkForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance, "Instance should have been deallocated. pottential memory leak",
                file: #filePath,
                line: #line
            )
        }
    }

    static var mockNSError: NSError {
        NSError(domain: "any error", code: 0)
    }

    static var mockURL: URL {
        URL(string: "http://any-url.com")!
    }

    static var mockData: Data {
        Data("any data".utf8)
    }
    static let mockEmptyData = Data()
    static let mockAnyURL = URL(string: "https://example.com")!
   // static let anyData = Data("Any data".utf8)
    static let anyError = NSError(domain: "any error", code: 1)
    static let anyHTTPURLResponse = HTTPURLResponse(
        url: mockURL, statusCode: .zero,
        httpVersion: nil, headerFields: [:]
    )

    static let nonHTTPURLResponse = URLResponse(
        url: mockURL, mimeType: nil,
        expectedContentLength: .zero, textEncodingName: nil
    )

}
