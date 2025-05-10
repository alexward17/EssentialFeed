import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public class LoadResourcePresenter {

    // MARK: - Types

    public typealias Mapper = (String) -> String

    // MARK: - Properties

    public final var resourceView: ResourceView
    public final var loadingView: FeedLoadingView
    public final let errorView: FeedErrorView
    public final var mapper: Mapper

    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    // MARK: - Initializer

    public init(resourceView: ResourceView, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    // MARK: - Helper Functions

    public final func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    public final func didFinishLoading(with ressource: String) {
        resourceView.display(mapper(ressource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public final func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
