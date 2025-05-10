import Foundation

public protocol ResourceView {
    associatedtype ResourseViewModel
    func display(_ viewModel: ResourseViewModel)
}

public class LoadResourcePresenter<Resource, View: ResourceView> {

    // MARK: - Types

    public typealias Mapper = (Resource) -> View.ResourseViewModel

    // MARK: - Properties

    public final var resourceView: View
    public final var loadingView: ResourceLoadingView
    public final let errorView: FeedErrorView
    public final var mapper: Mapper

    private var loadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the resource from the server"
        )
    }

    // MARK: - Initializer

    public init(resourceView: View, loadingView: ResourceLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    // MARK: - Helper Functions

    public final func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }

    public final func didFinishLoading(with ressource: Resource) {
        resourceView.display(mapper(ressource))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }

    public final func didFinishLoading(with error: Error) {
        errorView.display(.error(message: loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }

}
