//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Alex Ward on 2025-01-18.
//

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        feedImageView.alpha = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        feedImageView.alpha = 0
    }

    func fadeInFeedImage(_ image: UIImage?) {
        feedImageView.image = image
        UIView.animate(withDuration: 0.3, delay: 0.3) { [weak self] in
            self?.feedImageView.alpha = 1
        }
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
