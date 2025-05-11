import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    public let message: String
    public let date: String
    public let username: String

    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public final class ImageCommentsPresenter {

    // MARK: - Properties

    public static var title: String {
        return NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the image comments from the server"
        )
    }

    public static func map(
        _ comments: [ImageComment],
        currentDate: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        return ImageCommentsViewModel(comments: comments.map({
            ImageCommentViewModel(
                message: $0.massage,
                date: formatter.localizedString(for: $0.createdAt, relativeTo: currentDate),
                username: $0.username
            )
        }))
    }

}
