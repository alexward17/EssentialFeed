import XCTest
import EssentialFeed

public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

public struct FeedViewModel {
    let feed: [FeedImage]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public struct FeedLoadingViewModel {
    let isLoading: Bool
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}


class FeedPresenterTests: XCTestCase {

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
            .display(errorMessage: error.localizedDescription),
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

    private class FeedPresenter {

        final var feedView: FeedView
        final var loadingView: FeedLoadingView
        final let errorView: FeedErrorView

        init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
            self.feedView = feedView
            self.loadingView = loadingView
            self.errorView = errorView
        }

        func didStartLoadingFeed() {
            errorView.display(.noError)
            loadingView.display(FeedLoadingViewModel(isLoading: true))
        }

        final func didFinishLoadingFeed(with feed: [FeedImage]) {
            feedView.display(FeedViewModel(feed: feed))
            loadingView.display(FeedLoadingViewModel(isLoading: false))
        }

        final func didFinishLoadingFeed(with error: Error) {
            errorView.display(.error(message: error.localizedDescription))
            loadingView.display(FeedLoadingViewModel(isLoading: false))
        }
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
