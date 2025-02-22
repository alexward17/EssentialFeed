import UIKit

struct PrototypeFeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class PrototypeFeedViewController: UITableViewController {

    // MARK: - Lifecycle Functions

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        tableView.setContentOffset(CGPoint(x: .zero, y: -tableView.contentInset.top), animated: false)
    }

    // MARK: - Properties

    private var feed = [PrototypeFeedImageViewModel]()

    // MARK: - Helper Functions

    @IBAction
    final func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            if feed.isEmpty  {
                feed = PrototypeFeedImageViewModel.prototypeFeed
                tableView.reloadData()
            }
            refreshControl?.endRefreshing()
        }
    }

}



extension PrototypeFeedViewController {

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(String(describing: PrototypeFeedImageCell.self))) as? PrototypeFeedImageCell ?? PrototypeFeedImageCell()

        cell.configuew(with: feed[indexPath.row])

        return cell
    }
}

extension PrototypeFeedViewController {

    // MARK: - Previews

#if DEBUG

    @available(iOS 17, *)
    #Preview("Feed View Controller") {

        let controller = PrototypeFeedViewController()

        return controller
    }

#endif

}
