import UIKit

final class FeedImageCellController {

    // MARK: - Properties

    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    // MARK: - Initializers

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    // MARK: - Functions

    final func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        cell.configuew(with: model)
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            task = imageLoader.loadImageData(from: model.url, completion: { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = cell?.feedImageView.image != nil
                cell?.feedImageContainer.stopShimmering()
            })
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    final func preload() { task = imageLoader.loadImageData(from: model.url, completion: {_ in}) }

    deinit { task?.cancel() }
}
