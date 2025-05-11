import UIKit
import EssentialFeed

public final class ImageCommentCellController: CellController {

    private final let viewModel: ImageCommentViewModel

    public init(model: ImageCommentViewModel) {
        self.viewModel = model
    }

    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as? ImageCommentCell ?? ImageCommentCell()
        cell.messageLabel.text = viewModel.message
        cell.usernameLabel.text = viewModel.username
        cell.dateLabel.text = viewModel.date
        return cell
    }
    
    public func preload() {

    }
    
    public func cancelLoad() {

    }
    

}
