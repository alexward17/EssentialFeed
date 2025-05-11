import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject, ResourceLoadingView {

    public func display(_ viewModel: ResourceLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }

    // MARK: - Properties

    public final var onRefresh: (() -> Void)?

    // MARK: - Views

    public final lazy var view: UIRefreshControl = loadView(UIRefreshControl())

    // MARK: - Objc Functions

    @objc final func refresh() {
        onRefresh?()
    }

    private final func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }

}
