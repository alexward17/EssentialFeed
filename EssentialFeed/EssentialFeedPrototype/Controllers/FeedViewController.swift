import UIKit

public struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

public class FeedViewController: UITableViewController {

    // MARK: - Lifecycle Functions

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        tableView.setContentOffset(CGPoint(x: .zero, y: -tableView.contentInset.top), animated: false)
    }

    // MARK: - Properties

    private var feed = [FeedImageViewModel]()

    // MARK: - Helper Functions

    @IBAction
    final func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            if feed.isEmpty  {
                feed = FeedImageViewModel.prototypeFeed
                tableView.reloadData()
            }
            refreshControl?.endRefreshing()
        }
    }

}



extension FeedViewController {

    // MARK: - Table View Delegate

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(String(describing: FeedImageCell.self))) as? FeedImageCell ?? FeedImageCell()

        cell.configuew(with: feed[indexPath.row])

        return cell
    }
}

extension FeedViewController {

    // MARK: - Previews

#if DEBUG

    @available(iOS 17, *)
    #Preview("Feed View Controller") {

        let controller = FeedViewController()

        return controller
    }

#endif

}
