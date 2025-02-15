import UIKit

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {

    // MARK: - Properties

    public var refreshController: FeedRefreshViewController?
    private var cellControllers = [IndexPath: FeedImageCellController]()
    private let imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }

    private var onViewAppearing: ((FeedViewController) -> Void)?

    // MARK: - Initializers

    public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader?) {
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Functions

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: String(describing: FeedImageCell.self))
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view

        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }

        onViewAppearing = { vc in
            vc.refresh()
            vc.onViewAppearing = nil
        }
        refreshController?.refresh()
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewAppearing?(self)
    }

    // MARK: - Helper Functions

    @objc private func refresh() {
        refreshControl?.beginRefreshing()
    }

}

extension FeedViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cellController(forRowAt: $0).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }

    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers.removeValue(forKey: indexPath)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let cellController = FeedImageCellController(model: tableModel[indexPath.row], imageLoader: imageLoader!)
        cellControllers.updateValue(cellController, forKey: indexPath)
        return cellController
    }
}
