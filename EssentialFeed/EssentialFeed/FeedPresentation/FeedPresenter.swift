import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

// MARK: - Feed Presenter

public class FeedPresenter {
    
    // MARK: - Properties
    
    public final var feedView: FeedView
    public final var loadingView: ResourceLoadingView
    public final let errorView: FeedErrorView
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    // MARK: - Initializer
    
    public init(feedView: FeedView, loadingView: ResourceLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    // MARK: - Helper Functions
    
    public final func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public final func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public final func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
}
