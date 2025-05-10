import EssentialFeediOS
import EssentialFeed
import UIKit
import Combine

public final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    public init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    public func display(_ viewModel: FeedViewModel) {
        controller?.loadingControllers = [:]
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(
                loader: { [imageLoader] in
                    imageLoader(model.url)
                }
            )

            let view = FeedImageCellController(viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(model), delegate: adapter)

            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else { throw InvalidImageData() }
                    return image
                }
            )

            return view
        }
    }
}

public struct InvalidImageData: Error {}
