import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(
        feedLoader: @escaping () -> FeedLoader.Publisher,
        imageLoader:  @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
            let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
                loader: { feedLoader().dispatchOnMainQueue() }
            )

            let refreshController = FeedRefreshViewController()
            refreshController.onRefresh = presentationAdapter.loadResource
            let feedController = ListViewController(refreshController: refreshController)

            presentationAdapter.presenter = LoadResourcePresenter(
                resourceView: FeedViewAdapter(
                    controller: feedController,
                    imageLoader: { imageLoader($0).dispatchOnMainQueue() }
                ),
                loadingView: WeakRefVirtualProxy(refreshController),
                errorView: WeakRefVirtualProxy(feedController),
                mapper: FeedPresenter.map
            )

            return feedController
        }
}
