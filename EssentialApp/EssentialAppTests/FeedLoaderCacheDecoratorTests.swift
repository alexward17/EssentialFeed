// MARK: - NUGGET: A Decorator maintains the same interface as the Decoratee
import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        expect(makeSUT(loaderResult: .success(feed)), toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailre() {
        expect(makeSUT(loaderResult: .failure(Self.anyNSError)), toCompleteWith: .failure(Self.anyNSError))
    }

    func test_load_cachesLoadedFeedOnloaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load { _ in }

        XCTAssertEqual(cache.messages, [.save(feed)])
    }

    func test_load_doesNotCacheOnLoaderFailre() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(Self.anyNSError), cache: cache)

        sut.load { _ in }

        XCTAssertEqual(cache.messages, [])
    }

    // MARK: - Helpers

    private final func makeSUT(
        loaderResult: FeedLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

private class CacheSpy: FeedCache {

    // MARK: - Types

    enum Message: Equatable {
        case save([FeedImage])
    }

    // MARK: - Properties

    private(set) var messages = [Message]()

    // MARK: - Helpers

    func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
        messages.append(.save(feed))
        completion(.success(Void()))
    }

}
