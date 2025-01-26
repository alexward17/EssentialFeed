import XCTest
import EssentialFeediOS

extension FeedViewController {

    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
        }
        replaceRefreshControlWithFakeForiOS17Support()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }

    func replaceRefreshControlWithFakeForiOS17Support() {
        let mockRefresh = MockRefreshControl()

        refreshControl?.allTargets.forEach({ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                mockRefresh.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        })

        refreshControl = mockRefresh
    }

    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_loadFeedActions_requestFeedFromLoader() {
        let (sut, loaderSpy) = makeSUT()

        XCTAssertEqual(loaderSpy.loadCallCount, .zero)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCallCount, 1)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loaderSpy.loadCallCount, 2)

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loaderSpy.loadCallCount, 3)
    }

    func test_viewDidLoad_loadingIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: .zero)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) ->
    (sut: FeedViewController, loader: LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(loader: loaderSpy)
        trackForMemoryLeaks(loaderSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loaderSpy)
    }

    class LoaderSpy: FeedLoader {

        // MARK: - Properties

        final var loadCallCount: Int {
            completions.count
        }

        private var completions: [(FeedLoader.Result) -> Void] = []

        // MARK: - Helper Functions

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }

    }

}

public extension UIRefreshControl {

    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }

}

private class MockRefreshControl: UIRefreshControl {

    private var _isRefreshing = false

    override var isRefreshing: Bool { _isRefreshing }

    override func beginRefreshing() {
        _isRefreshing = true
    }

    override func endRefreshing() {
        _isRefreshing = false
    }
}
