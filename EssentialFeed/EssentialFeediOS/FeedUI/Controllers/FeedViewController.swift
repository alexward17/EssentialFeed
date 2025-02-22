import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView {

    // MARK: - Properties

    var delegate: FeedViewControllerDelegate?
    private var cellControllers = [IndexPath: FeedImageCellController]()
    final var tableModel = [FeedImageCellController]() { didSet { tableView.reloadData() } }

    private var onViewAppearing: ((FeedViewController) -> Void)?

    // MARK: - Lifecycle Functions

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: String(describing: FeedImageCell.self))
        tableView.prefetchDataSource = self

        onViewAppearing = { vc in
            vc.refresh()
            vc.onViewAppearing = nil
        }
        refresh()
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewAppearing?(self)
    }

    // MARK: - Helper Functions

    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }

}

extension FeedViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoads(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(forRowAt: $0).preload() }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoads)
    }

    private func cancelCellControllerLoads(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }


    func display(_ viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }

}
