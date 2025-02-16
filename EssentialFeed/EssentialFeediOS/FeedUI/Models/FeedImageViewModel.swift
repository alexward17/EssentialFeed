import Foundation

final class FeedImageViewModel<Image> {

    // MARK: - Types

    typealias Observer<T> = (T) -> Void

    // MARK: - Properties

    private var imageLoader: FeedImageDataLoader
    private let model: FeedImage
    private var task: FeedImageDataLoaderTask?
    private let imageTransformer: (Data) -> Image?

    var description: String? {
        model.description
    }

    var location: String? {
        model.location
    }

    var hasLocation: Bool {
        location != nil
    }

    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

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
