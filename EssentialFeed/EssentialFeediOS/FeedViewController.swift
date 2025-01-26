import UIKit

public class FeedViewController: UITableViewController {

    // MARK: - Properties

    private let loader: FeedLoader
    private var tableModel = [FeedImage]()

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
        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.tableModel = feed
                self?.tableView.reloadData()
            case .failure(let error):
                break
            }
            self?.refreshControl?.endRefreshing()
        }
    }

}

extension FeedViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedImageCell.self), for: indexPath) as? FeedImageCell ?? FeedImageCell()

        cell.configuew(with: tableModel[indexPath.row])

        return cell
    }

}
