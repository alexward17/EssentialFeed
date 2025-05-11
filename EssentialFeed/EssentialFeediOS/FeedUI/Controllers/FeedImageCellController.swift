import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView, CellController {

    public typealias ResourceViewModel = UIImage

    // MARK: - Properties
    
    private let viewModel: FeedImageViewModel
    private let delegate: FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()

    // MARK: - Initializers

    public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    // MARK: - Helper Functions

    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell
    }

    public func preload() {
        delegate.didRequestImage()
    }

    public func cancelLoad() {
        delegate.didCancelImageRequest()
    }

    public func display(_ viewModel: UIImage) {
        cell.feedImageView.image = viewModel
    }

    public func display(_ viewModel: EssentialFeed.ResourceLoadingViewModel) {
        cell.feedImageContainer.isShimmering = viewModel.isLoading
    }

    public func display(_ viewModel: EssentialFeed.ResourceErrorViewModel) {
        cell.feedImageRetryButton.isHidden = viewModel.message == nil

    }
}
