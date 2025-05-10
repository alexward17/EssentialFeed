import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {

    func test_titleIsLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to be sent to the view")
    }

    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isloading: true)
        ])
    }

    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        sut.didFinishLoadingFeed(with: feed)
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isloading: false)
        ])
    }

    func test_didFinishLoadingFeed_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        let error = Self.anyError
        sut.didFinishLoadingFeed(with: error)
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("GENERIC_CONNECTION_ERROR")),
            .display(isloading: false)
        ])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)

        if value == key {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }

        return value
    }

    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isloading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }

        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isloading: Bool)
            case display(feed: [FeedImage])
        }

        var messages = Set<Message>()
    }

    func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), url: XCTestCase.mockURL)
    }

    func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        return (feed, feed.toLocal())
    }

}
