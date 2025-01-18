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

        let feedData = feed[indexPath.row]

        cell.descriptionLabel.text = feedData.description
        cell.locationLabel.text = feedData.location
        cell.descriptionLabel.isHidden = feedData.description == nil
        cell.locationLabel.isHidden = feedData.location == nil
        cell.feedImageView.image = UIImage(named: feedData.imageName)
        return cell
    }

}
