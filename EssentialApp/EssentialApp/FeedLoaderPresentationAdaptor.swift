import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?

    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }

    public func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        cancellable = feedLoader()
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let failure) = completion else {
                        return
                    }
                    self?.presenter?.didFinishLoadingFeed(with: failure)
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
                }
            )

    }
}
