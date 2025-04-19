import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {

    // MARK: - Properties

    final let decoratee: FeedLoader
    final let cache: FeedCache

    // MARK: - Initializers

    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    // MARK: - Helpers

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: { [weak self] result in
            completion(result.map({ feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            }))
        })
    }

}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
