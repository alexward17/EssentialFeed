import UIKit

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
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
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))

            guard let self, let feed = try? result.get() else { return }

            feedView?.display(FeedViewModel(feed: feed))
        }
    }

}
