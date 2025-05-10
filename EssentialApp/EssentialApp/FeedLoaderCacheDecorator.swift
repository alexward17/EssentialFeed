import EssentialFeed

public class FeedLoaderCacheDecorator {

    // MARK: - Properties

    final let decoratee: LocalFeedLoader
    final let cache: FeedCache

    // MARK: - Initializers

    public init(decoratee: LocalFeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    // MARK: - Helpers

    public func load(completion: @escaping ( Swift.Result<[FeedImage], Error>) -> Void) {
        decoratee.load(completion: { [weak self] result in
            completion(result.map({ feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            }))
        })
    }

}

public extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
