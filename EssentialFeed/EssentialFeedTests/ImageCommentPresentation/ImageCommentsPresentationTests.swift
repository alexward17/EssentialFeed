import XCTest
import EssentialFeed

class ImageCommentsPresentationTests: XCTestCase {
    func test_titleIsLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let now = Date()

        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let comments = [
            ImageComment(
                id: UUID(),
                massage: "a message",
                createdAt: now.adding(minutes: -5),
                username: "a username"
            ),
            ImageComment(
                id: UUID(),
                massage: "another message",
                createdAt: now.adding(days: -1),
                username: "another username"
            )
        ]

        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )

        XCTAssertEqual(
            viewModel.comments, [
                ImageCommentViewModel(
                    message: "a message",
                    date: "5 minutes ago",
                    username: "a username"
                ),
                ImageCommentViewModel(
                    message: "another message",
                    date: "1 day ago",
                    username: "another username"
                )
            ]
        )
    }

    // MARK: - Helpers

    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)

        if value == key {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }

        return value
    }

    func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), url: XCTestCase.mockURL)
    }

    func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        return (feed, feed.toLocal())
    }

}
