public final class FeedUIComposer {

    private init() {}
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)

        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)

        return feedController
    }

    // THIS CLOSURE IS THE ADDAPTER PATTERN, it allows `adaptation` of un-matching APIs.
    // In thise case onRefresh delivers [FeedImage] that are adapted to [FeedImageCellController] on which the FeedViewController depends
    private static func adaptFeedToCellControllers(
        forwardingTo controller: FeedViewController,
        loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
            return { [weak controller] feed in
                controller?.tableModel = feed.map({ FeedImageCellController(model: $0, imageLoader: loader) })
            }
    }

}
