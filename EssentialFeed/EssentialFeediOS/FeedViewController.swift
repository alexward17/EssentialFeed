import UIKit

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public class FeedViewController: UITableViewController {

    // MARK: - Properties

    private let feedLoader: FeedLoader
    private var loaderTasks = [IndexPath : FeedImageDataLoaderTask]()
    private let imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()

    private var onViewAppearing: ((FeedViewController) -> Void)?

    // MARK: - Initializers

    public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader?) {
        self.feedLoader = feedLoader
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
        feedLoader.load { [weak self] result in
            self?.refreshControl?.endRefreshing()

            guard let feed = try? result.get() else { return }
            self?.tableModel = feed
            self?.tableView.reloadData()
        }
    }

}

extension FeedViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedImageCell.self), for: indexPath) as? FeedImageCell ?? FeedImageCell()
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()

        cell.configuew(with: tableModel[indexPath.row])
        guard let task = imageLoader?.loadImageData(from: tableModel[indexPath.row].url, completion: { [weak cell] result in
            let data = try? result.get()
            cell?.feedImageView.image = data.map(UIImage.init) ?? nil
            cell?.feedImageContainer.stopShimmering()
        }) else { return cell }
        loaderTasks[indexPath] = task

        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loaderTasks[indexPath]?.cancel()
    }

}
