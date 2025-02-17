import UIKit

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

final class FeedPresenter {

    // MARK: - Types

    typealias Observer<T> = (T) -> Void

    // MARK: - Properties

    private final var feedLoader: FeedLoader
    final var feedView: FeedView?
    final var loadingView: FeedLoadingView?

    // MARK: - Initializers

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    final func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            self?.loadingView?.display(isLoading: false)

            guard let self, let feed = try? result.get() else { return }

            feedView?.display(feed: feed)
        }
    }

}
