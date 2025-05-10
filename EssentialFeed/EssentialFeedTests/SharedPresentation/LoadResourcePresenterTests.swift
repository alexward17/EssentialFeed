import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to be sent to the view")
    }

    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoading()
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isloading: true)
        ])
    }

    func test_didFinishLoadingResource_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        sut.didFinishLoading(with: "resource")
        XCTAssertEqual(view.messages, [
            .display(resourceViewModel: "resource view model"),
            .display(isloading: false)
        ])
    }

    func test_didFinishLoading_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        let error = Self.anyError
        sut.didFinishLoading(with: error)
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("GENERIC_CONNECTION_ERROR")),
            .display(isloading: false)
        ])
    }

    // MARK: - Helpers

    private typealias SUT = LoadResourcePresenter<String, ViewSpy>

    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(resourceView: view, loadingView: view, errorView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)

        if value == key {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }

        return value
    }

    private class ViewSpy: FeedErrorView, FeedLoadingView, ResourceView {
        typealias ResourseViewModel = String

        func display(_ viewModel: ResourseViewModel) {
            messages.insert(.display(resourceViewModel: viewModel))
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
            case display(resourceViewModel: String)
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
