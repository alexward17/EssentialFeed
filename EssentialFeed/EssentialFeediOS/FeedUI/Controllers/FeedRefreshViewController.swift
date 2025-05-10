import UIKit
import EssentialFeed

public protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, ResourceLoadingView {

    public func display(_ viewModel: ResourceLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }

    // MARK: - Properties

    private let delegate: FeedRefreshViewControllerDelegate

    // MARK: - Views

    public final lazy var view: UIRefreshControl = loadView(UIRefreshControl())

    // MARK: - Initializers

    public init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }

    // MARK: - Objc Functions

    @objc final func refresh() {
        delegate.didRequestFeedRefresh()
    }

    private final func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }

}
