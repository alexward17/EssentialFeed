import Foundation

final class FeedViewModel {

    // MARK: - Properties

    private final var feedLoader: FeedLoader
    final var onChange: ((FeedViewModel) -> Void)?
    final var onFeedLoad: (([FeedImage]) -> Void)?

    private(set) final var isLoading: Bool = false {
        didSet { onChange?(self) }
    }


    // MARK: - Initializers

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    final func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            guard let self, let feed = try? result.get() else {
                self?.isLoading = false
                return
            }
            isLoading = false
            onFeedLoad?(feed)
        }
    }

}
