//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Alex Ward on 2025-01-26.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public var feedImageView = UIImageView()

    public private(set) lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryActionButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    @objc private func retryActionButtonTapped() {
        onRetry?()
    }
}
