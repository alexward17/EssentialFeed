import UIKit

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {

    // MARK: - Properties

    public var refreshController: FeedRefreshViewController?
    private var loaderTasks = [IndexPath : FeedImageDataLoaderTask]()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedImageCell.self), for: indexPath) as? FeedImageCell ?? FeedImageCell()
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        cell.configuew(with: tableModel[indexPath.row])
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            loaderTasks[indexPath] = imageLoader?.loadImageData(from: tableModel[indexPath.row].url, completion: { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = cell?.feedImageView.image != nil
                cell?.feedImageContainer.stopShimmering()
            })
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            loaderTasks[$0] = imageLoader?.loadImageData(from: tableModel[$0.row].url, completion: {_ in})
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cancelTask(forRowAt: $0)
        }
    }

    private func cancelTask(forRowAt indexPath: IndexPath) {
        loaderTasks[indexPath]?.cancel()
        loaderTasks[indexPath] = nil
    }
}
