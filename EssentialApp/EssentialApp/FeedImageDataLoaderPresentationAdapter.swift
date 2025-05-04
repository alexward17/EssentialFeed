import EssentialFeed
import EssentialFeediOS
import Combine


public final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: FeedImagePresenter<View, Image>?

    public init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    public func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model

        cancellable = imageLoader(model.url)
            .sink(
                receiveCompletion: { [weak self] in
                    guard case let .failure(error) = $0 else { return }
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }, receiveValue: { [weak self] in
                    self?.presenter?.didFinishLoadingImageData(with: $0, for: model)
                }
            )
    }

    public func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
