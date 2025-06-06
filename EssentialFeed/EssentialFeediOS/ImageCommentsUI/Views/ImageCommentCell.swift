import UIKit

public final class ImageCommentCell: UITableViewCell {

    // MARK: - Class Constants

    static var identifier: String { String(describing: self) }

    // MARK: - Views

    public lazy var container = UIView()

    public lazy var outerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            topStack, messageLabel
        ])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8

        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    public lazy var topStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            usernameLabel, dateLabel
        ])

        stackView.axis = .horizontal
        stackView.distribution = .fill

        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    public lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    public lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 6
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .lightGray
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    public lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

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
        accessibilityIdentifier = "image-comment-cell"
        selectionStyle = .none
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        container.addSubview(outerStack)

        container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        container.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        container.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true

        outerStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6).isActive = true
        outerStack.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 20).isActive = true
        outerStack.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
    }

}

// MARK: - Previews

#if DEBUG

@available(iOS 17, *)
#Preview("Image Comment Cell") {
    let cell = ImageCommentCell()
    cell.heightAnchor.constraint(equalToConstant: 700).isActive = true
    cell.messageLabel.text = "clvfa;dsbdbf.skjdfbsdbfvds.jhbvfd.sjhdvfb.sjdfhvbs.djfvhbs.jdfhvb.sjdhfbv.jshbv.jshbdvfszdfkjvnskdfvjnskdfvjksdfvbvksdfbvksjfdbvksbfdkvjsdfbvksjdfbvksjdfbvksjdfbvksjdfbvksjdbfvksjvbdfskjvfbkjbvfdksjdbfvkjsbdfkvjsbdkfvjbvhgvkhgv2skdfjvbskdjfvbksdjfvbskjfvbksjdfb.jshdbfv.ifvhalsdjfb sd;fh bsdlfjhbaldfjhb sjdfhb l.sdfhjzb .zjdfhb .ùhz b.jdfhb v.zjhbdf .zjhdfb .zjhdbf .zjhfb .zjhdfb .zjhdfb .zjdbf .zjhbf .jzhbf .jhzbdf .bzdf. bhzdf. bzd.j fbz.djhfb z.jdhfb .zjhbd .zjhdbf .jzhdbf .zjhb .dfzjhb  a;sd"
    cell.usernameLabel.text = "Bobby Lee"
    cell.dateLabel.text =  "110 years ago"

    return cell
}

#endif
