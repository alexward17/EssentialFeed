import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?

    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }

    public func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        cancellable = feedLoader()
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let failure) = completion else {
                        return
                    }
                    self?.presenter?.didFinishLoading(with: failure)
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                }
            )

    }
}
