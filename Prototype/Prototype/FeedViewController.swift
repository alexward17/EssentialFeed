import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {

    private let feed = FeedImageViewModel.prototypeFeed

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(String(describing: FeedImageCell.self))) as? FeedImageCell ?? FeedImageCell()

        cell.configuew(with: feed[indexPath.row])

        return cell
    }

}

extension FeedImageCell {
    func configuew(with model: FeedImageViewModel) {
        descriptionLabel.text = model.description
        locationLabel.text = model.location
        descriptionLabel.isHidden = model.description == nil
        locationLabel.isHidden = model.location == nil
        fadeInFeedImage(UIImage(named: model.imageName))
    }
}
