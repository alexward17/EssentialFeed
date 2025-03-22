import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to be sent to the view")
    }

    // MARK: - Helpers

    private class ViewSpy {
        let messages = [Any]()
    }

}
