import UIKit

public class FeedViewController: UITableViewController {

    // MARK: - Properties//

    private let loader: FeedLoader

    private var onViewAppearing: ((FeedViewController) -> Void)?

    // MARK: - Initializers

    public init(loader: FeedLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Functions

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        onViewAppearing = { vc in
            vc.refresh()
            vc.onViewAppearing = nil
        }
        load()
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewAppearing?(self)
    }

    // MARK: - Helper Functions

    @objc private func refresh() {
        refreshControl?.beginRefreshing()
    }

    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }

}

public extension FeedViewController {

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }

}
