// MARK: - NUGGET: A Decorator maintains the same interface as the Decoratee
import XCTest
import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {

    // MARK: - Properties

    final let decoratee: FeedLoader

    // MARK: - Initializers

    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }

    // MARK: - Helpers

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
    

}

class FeedLoaderCacheDecoratorTests: XCTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let loader = LoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailre() {
        let loader = LoaderStub(result: .failure(Self.anyNSError))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)

        expect(sut, toCompleteWith: .failure(Self.anyNSError))
    }

}
