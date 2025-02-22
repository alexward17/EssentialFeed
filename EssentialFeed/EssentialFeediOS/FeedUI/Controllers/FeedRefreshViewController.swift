import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject {

    // MARK: - Properties

    var delegate: FeedRefreshViewControllerDelegate?

    // MARK: - Views

    @IBOutlet public var view: UIRefreshControl?

    // MARK: - Objc Functions

    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }

}

// MARK: - Feed Loading View Implamentation

extension FeedRefreshViewController: FeedLoadingView {

    func display(_ viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
    }

}
