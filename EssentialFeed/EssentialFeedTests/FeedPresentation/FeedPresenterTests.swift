import XCTest

public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
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

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class FeedPresenter {

        final var loadingView: FeedLoadingView
        final let errorView: FeedErrorView

        init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
            self.loadingView = loadingView
            self.errorView = errorView
        }

        func didStartLoadingFeed() {
            errorView.display(.noError)
            loadingView.display(FeedLoadingViewModel(isLoading: true))
        }
    }

    private class ViewSpy: FeedErrorView, FeedLoadingView {
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isloading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }

        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isloading: Bool)
        }

        var messages = Set<Message>()
    }

}
