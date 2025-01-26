import XCTest
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_init_loadFeedActions_requestFeedFromLoader() {
        let (sut, loaderSpy) = makeSUT()

        XCTAssertEqual(loaderSpy.loadFeedCallCount, .zero)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadFeedCallCount, 1)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loaderSpy.loadFeedCallCount, 2)

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loaderSpy.loadFeedCallCount, 3)
    }

    func test_viewDidLoad_loadingIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: .zero)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading()

        assertThat(sut, isRendering: [])

        loader.completeFeedLoading(with: [image0])

        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)

        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentrenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location", url: Self.mockURL)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError()

        assertThat(sut, isRendering: [image0])
    }

    func test_feedImageView_loadsURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com"))
        let image1 = makeImage(url: URL(string: "http://url-1.com"))
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateImageVisible(at: .zero)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])

        sut.simulateImageVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) ->
    (sut: FeedViewController, loader: LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(feedLoader: loaderSpy, imageLoader: loaderSpy)
        trackForMemoryLeaks(loaderSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loaderSpy)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL? = nil) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url ?? Self.mockURL)
    }

    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, line: UInt = #line, file: StaticString = #filePath) {
        let view = sut.feedImageView(at: index) as? FeedImageCell

        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertTrue(view?.isShowingLocation ?? false, file: file, line: line)
        XCTAssertEqual(view?.locationText, image.location, file: file, line: line)
        XCTAssertEqual(view?.descriptionLabel.text, image.description, file: file, line: line)
    }

    private func assertThat(_ sut: FeedViewController, isRendering images: [FeedImage], line: UInt = #line, file: StaticString = #filePath) {
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), images.count, file: file, line: line)
        images.enumerated().forEach {
            assertThat(sut, hasViewConfiguredFor: $0.element, at: $0.offset, line: line, file: file)
        }
    }

    class LoaderSpy: FeedLoader, FeedImageDataLoader {

        // MARK: - Feed Loader Properties

        final var loadFeedCallCount: Int {
            feedRequests.count
        }

        private var feedRequests: [(FeedLoader.Result) -> Void] = []

        // MARK: - Feed Loader Helper Functions

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = .zero) {
            feedRequests[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int = .zero) {
            feedRequests[index](.failure(XCTestCase.anyError))
        }

        // MARK: - Feed Image Data Loader Properties

        final var loadedImageURLs = [URL]()

        // MARK: - Feed Image Data LoaderFunctions

        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
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

extension FeedViewController {

    // MARK: - Properties

    var feedImageSection: Int {
        .zero
    }

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }

    // MARK: - Helpers

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

    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let idxPath = IndexPath(row: row, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: idxPath)

    }

    func simulateImageVisible(at row: Int) {
        _ = feedImageView(at: row)
    }

}

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    var locationText: String? {
        locationLabel.text
    }
    var descriptionText: String? {
        locationLabel.text
    }
}
