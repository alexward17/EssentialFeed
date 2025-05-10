import UIKit
import EssentialFeed
import EssentialFeediOS

public final class WeakRefVirtualProxy<T: AnyObject> {
    public weak var object: T?

   public init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    public func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    public func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}
