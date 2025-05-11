import XCTest
import EssentialFeed

class ImageCommentsPresentationTests: XCTestCase {
    func test_titleIsLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let feed = uniqueImageFeed().models

        let viewModel = ImageCommentsPresenter.map(feed)

        XCTAssertEqual(viewModel.feed, feed)
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
