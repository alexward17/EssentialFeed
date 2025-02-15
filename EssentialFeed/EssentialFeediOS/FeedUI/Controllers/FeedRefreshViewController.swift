import UIKit

public final class FeedRefreshViewController: NSObject {

    // MARK: - Properties

    private final var feedLoader: FeedLoader

    final var onRefresh: (([FeedImage]) -> Void)?

    // MARK: - Views

    public final lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    // MARK: - Initializers

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    // MARK: - Objc Functions

    @objc final func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() { self?.onRefresh?(feed) }
            self?.view.endRefreshing()
        }
    }
}
