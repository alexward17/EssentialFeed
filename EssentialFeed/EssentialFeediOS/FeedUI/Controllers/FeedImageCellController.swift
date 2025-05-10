import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView, ResourceView, ResourceLoadingView, ResourceErrorView {

    public typealias ResourceViewModel = UIImage

    // MARK: - Properties
    
    private let viewModel: FeedImageViewModel<UIImage>
    private let delegate: FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()

    // MARK: - Initializers

    public init(viewModel: FeedImageViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    // MARK: - Helper Functions

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        delegate.didCancelImageRequest()
    }

    public func display(_ viewModel: FeedImageViewModel<UIImage>) {

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
