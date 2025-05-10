import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public class LoadResourcePresenter<Resource, View: ResourceView> {

    // MARK: - Types

    public typealias Mapper = (Resource) throws -> View.ResourceViewModel

    // MARK: - Properties

    public final var resourceView: View
    public final var loadingView: ResourceLoadingView
    public final let errorView: ResourceErrorView
    public final var mapper: Mapper

    private var loadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the resource from the server"
        )
    }

    // MARK: - Initialize

    public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView, mapper: @escaping Mapper) {
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
        do {
            resourceView.display(try mapper(ressource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }

    public final func didFinishLoading(with error: Error) {
        errorView.display(.error(message: loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }

}
