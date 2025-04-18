import UIKit
import EssentialFeed

public struct FeedViewModel {
    let feed: [FeedImage]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public struct FeedLoadingViewModel {
    let isLoading: Bool
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {

    // MARK: - Types

    typealias Observer<T> = (T) -> Void

    // MARK: - Properties

    final var feedView: FeedView
    final var loadingView: FeedLoadingView
    final let errorView: FeedErrorView

    private var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                tableName: "Feed",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "Error message displayed when we can't load the image feed from the server")
    }

    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                tableName: "Feed",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "Error message displayed when we can't load the image feed from the server")
    }

    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    final func didStartLoadingFeed() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            errorView.display(.noError)
            loadingView.display(FeedLoadingViewModel(isLoading: true))
        }
    }

    final func didFinishLoadingFeed(with feed: [FeedImage]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            feedView.display(FeedViewModel(feed: feed))
            loadingView.display(FeedLoadingViewModel(isLoading: false))
        }
    }

    final func didFinishLoadingFeed(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            errorView.display(.error(message: feedLoadError))
            loadingView.display(FeedLoadingViewModel(isLoading: false))
        }
    }

}
