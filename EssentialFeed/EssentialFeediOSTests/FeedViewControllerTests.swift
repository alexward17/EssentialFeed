import XCTest

class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(loader: loaderSpy)

        XCTAssertEqual(loaderSpy.loadCallCount, .zero)
    }

    class LoaderSpy {
        private(set) var loadCallCount = 0

    }

}
