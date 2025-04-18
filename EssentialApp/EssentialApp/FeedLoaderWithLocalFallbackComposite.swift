import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {

    // MARK: - Properties

    final let primary: FeedLoader
    final let fallback: FeedLoader

    // MARK: - Initializers

    public init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primary = primaryLoader
        self.fallback = fallbackLoader
    }

    // MARK: - Helpers

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        })
    }

}
