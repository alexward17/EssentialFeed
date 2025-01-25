import XCTest

class FeedViewController: UIViewController {

    // MARK: - Properties

    let loader: FeedViewControllerTests.LoaderSpy

    // MARK: - Initializers

    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.load()
    }

}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loaderSpy = LoaderSpy()
        _ = FeedViewController(loader: loaderSpy)

        XCTAssertEqual(loaderSpy.loadCallCount, .zero)
    }

    func test_viewDidLoad_loadsFeed() {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(loader: loaderSpy)
        
        sut.loadViewIfNeeded()

        XCTAssertEqual(loaderSpy.loadCallCount, 1)
    }

    class LoaderSpy {

        // MARK: - Properties

        private(set) var loadCallCount = 0

        // MARK: - Helper Functions

        final func load() {
            loadCallCount += 1
        }

    }

}
