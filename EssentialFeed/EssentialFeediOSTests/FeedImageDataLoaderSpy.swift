import EssentialFeed
import XCTest

class FeedImageDataLoaderSpy: FeedLoader, FeedImageDataLoader {

    // MARK: - Feed Loader Properties

    final var loadFeedCallCount: Int {
        feedRequests.count
    }

    private var feedRequests: [(FeedLoader.Result) -> Void] = []

    // MARK: - Feed Loader Helper Functions

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
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
