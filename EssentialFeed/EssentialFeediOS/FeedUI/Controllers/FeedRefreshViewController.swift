import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject {

    // MARK: - Properties

    private let delegate: FeedRefreshViewControllerDelegate

    // MARK: - Views

    @IBOutlet private var view: UIRefreshControl?

    // MARK: - Initializers

    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }

    // MARK: - Objc Functions

    @objc final func refresh() {
        delegate.didRequestFeedRefresh()
    }

}

// MARK: - Feed Loading View Implamentation

extension FeedRefreshViewController: FeedLoadingView {

    func display(_ viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
    }

}
