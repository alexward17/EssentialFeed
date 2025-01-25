import XCTest
import EssentialFeed

class FeedViewController: UIViewController {

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
        loader.load {_ in}
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

    class LoaderSpy: FeedLoader {

        // MARK: - Properties

        private(set) var loadCallCount = 0

        // MARK: - Helper Functions

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }

    }

}
