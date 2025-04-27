import UIKit

public class FeedImageCell: UITableViewCell {

    // MARK: - Properties

    public lazy var outerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            locationContainer,
            feedImageContainer,
            descriptionLabel
        ])

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8

        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    public lazy var locationContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pinContainer, locationLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    lazy var pinContainer: UIView = {
        let view = UIView()
        let pinIcon = UIImageView(image: UIImage(named: "icons8-location-48"))
        pinIcon.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        pinIcon.contentMode = .scaleAspectFit

        view.addSubview(pinIcon)

        view.widthAnchor.constraint(equalToConstant: 14).isActive = true
        view.heightAnchor.constraint(equalToConstant: 14).isActive = true

        pinIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pinIcon.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pinIcon.topAnchor.constraint(equalTo: view.topAnchor, constant: 3).isActive = true
        pinIcon.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        return view
    }()

    public lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.textColor = .lightGray
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.widthAnchor.constraint(equalToConstant: 250).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    public lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 6
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    public lazy var feedImageContainer: UIView = {
        let container = UIView()
        container.addSubview(feedImageView)
        container.addSubview(feedImageRetryButton)
        container.clipsToBounds = true
        container.layer.cornerRadius = 8

        feedImageView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        feedImageView.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        feedImageView.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        feedImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        feedImageView.heightAnchor.constraint(equalToConstant: 313).isActive = true

        feedImageRetryButton.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        feedImageRetryButton.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        feedImageRetryButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        feedImageRetryButton.widthAnchor.constraint(equalToConstant: 60).isActive = true

        container.translatesAutoresizingMaskIntoConstraints = false

        return container
    }()

    public lazy var feedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // accessibilityIdentifier added for UI acceptance tests
        imageView.accessibilityIdentifier = "feed-image-view"

        return imageView
    }()

    public private(set) lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryActionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var onRetry: (() -> Void)?

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private final func setupViews() {

        // accessibilityIdentifier added for UI acceptance tests
        accessibilityIdentifier = "feed-image-cell"
        selectionStyle = .none
        contentView.addSubview(outerStack)

        locationContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 114).isActive = true

        outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        outerStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        outerStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        outerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
    }

    @objc private func retryActionButtonTapped() {
        onRetry?()
    }
}
