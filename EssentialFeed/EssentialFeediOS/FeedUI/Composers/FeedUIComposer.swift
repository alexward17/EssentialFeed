import UIKit
public final class FeedUIComposer {

    private init() {}
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)
        feedPresenter.loadingView = WeakRefVirtualProxy(refreshController)
        feedPresenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)

        return feedController
    }

}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
    

}

private final class FeedViewAdapter: FeedView {

    // MARK: - Properties

    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader

    // MARK: - Initializers

    init(controller: FeedViewController? = nil, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }

    // MARK: - Helper Functions

    final func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map({
            FeedImageCellController(
                viewModel: FeedImageViewModel(
                    model: $0,
                    imageLoader: loader,
                    imageTransformer: UIImage.init
                )
            )
        })
    }

    // THIS IS THE ADDAPTER PATTERN, it allows `adaptation` of un-matching APIs.
    // In thise case onRefresh delivers [FeedImage] that are adapted to [FeedImageCellController] on which the FeedViewController depends

}
