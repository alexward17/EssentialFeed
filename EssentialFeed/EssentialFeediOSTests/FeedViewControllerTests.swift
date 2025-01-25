import XCTest
import EssentialFeed

class FeedViewController: UITableViewController {

    // MARK: - Properties

    let loader: FeedLoader

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
        load()
    }

    // MARK: - Helper Functions

    @objc
    private func load() {
        loader.load { _ in }
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

        private(set) var loadCallCount = 0

        // MARK: - Helper Functions

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
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
