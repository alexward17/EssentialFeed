import UIKit

public final class FeedRefreshViewController: NSObject {

    // MARK: - Properties

    private let viewModel: FeedViewModel

    // MARK: - Views

    public final lazy var view: UIRefreshControl = binded(UIRefreshControl())

    // MARK: - Initializers

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - Objc Functions

    @objc final func refresh() {
        viewModel.loadFeed()
    }

    private final func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        viewModel.onChange = { [weak self] viewModel in
            viewModel.isLoading
            ? self?.view.beginRefreshing()
            : self?.view.endRefreshing()
        }
        return view
    }

}
