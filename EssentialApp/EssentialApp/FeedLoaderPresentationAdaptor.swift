import EssentialFeed
import EssentialFeediOS
import Combine

public final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?

    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }

    public func loadResource() {
        presenter?.didStartLoading()
        cancellable = loader()
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let failure) = completion else {
                        return
                    }
                    self?.presenter?.didFinishLoading(with: failure)
                }, receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                }
            )

    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    public func didRequestImage() { loadResource() }
    public func didCancelImageRequest() { cancellable?.cancel() }
}
