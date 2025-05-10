import Foundation

// MARK: - Feed Presenter

public class FeedPresenter {

    // MARK: - Properties

    public static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the image feed from the server"
        )
    }

    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }

}
