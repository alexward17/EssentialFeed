import XCTest
import EssentialFeed

class FeedViewController: UITableViewController {

    // MARK: - Properties

    let loader: FeedLoader

    var onViewAppearing: ((FeedViewController) -> Void)?

    // MARK: - Initializers

    init(loader: FeedLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        onViewAppearing = { vc in
            vc.refresh()
            vc.onViewAppearing = nil
        }
        load()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewAppearing?(self)
    }

    // MARK: - Helper Functions

    @objc private func refresh() {
        refreshControl?.beginRefreshing()
    }

    @objc private func load() {
        loader.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }

}

private extension FeedViewController {

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
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loaderSpy) = makeSUT()

        XCTAssertEqual(loaderSpy.loadCallCount, .zero)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loaderSpy) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loaderSpy.loadCallCount, 1)
    }

    func test_pullToRefresh_loadsFeed() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loaderSpy.loadCallCount, 2)

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loaderSpy.loadCallCount, 3)
    }

    func test_viewDidLoad_showLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)

        sut.refreshControl?.endRefreshing()
        sut.simulateAppearance()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }

    func test_viewDidLoad_hidesIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }

    func test_pullToRefreshShowLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
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

        func completeFeedLoading() {
            completions[0](.success([]))
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
