import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {

    func display(_ viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }


    // MARK: - Properties

    private let presenter: FeedPresenter

    // MARK: - Views

    public final lazy var view: UIRefreshControl = loadView(UIRefreshControl())

    // MARK: - Initializers

    init(presenter: FeedPresenter) {
        self.presenter = presenter
        super.init()
    }

    // MARK: - Objc Functions

    @objc final func refresh() {
        presenter.loadFeed()
    }

    private final func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }

}
