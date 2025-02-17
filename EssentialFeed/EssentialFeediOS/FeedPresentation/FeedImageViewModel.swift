import Foundation

final class FeedImageViewModel<Image> {

    // MARK: - Types

    typealias Observer<T> = (T) -> Void

    // MARK: - Private Properties

    private final var imageLoader: FeedImageDataLoader
    private final let model: FeedImage
    private final var task: FeedImageDataLoaderTask?
    private final let imageTransformer: (Data) -> Image?

    // MARK: - Properties

    final var onImageLoad: Observer<Image>?
    final var onImageLoadingStateChange: Observer<Bool>?
    final var onShouldRetryImageLoadStateChange: Observer<Bool>?

    // MARK: - Computed Variables

    final var description: String? { model.description }
    final var location: String? { model.location }
    final var hasLocation: Bool { location != nil }

    // MARK: - Initializers

    init(
        model: FeedImage,
        imageLoader: FeedImageDataLoader,
        imageTransformer: @escaping (Data) -> Image?
    ) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    final func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
            self?.handle(result)
        })
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }

    final func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }

}
