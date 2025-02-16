import UIKit

final class FeedImageCellController {

    // MARK: - Properties

    private let viewModel: FeedImageViewModel<UIImage>


    // MARK: - Initializers

    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    // MARK: - Functions

    final func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }

    private final func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData

        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }

        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }

        return cell
    }

    final func preload() { viewModel.loadImageData() }

    final func cancelLoad() { viewModel.cancelImageDataLoad() }
}
