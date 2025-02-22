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

    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com"))
        let image1 = makeImage(url: URL(string: "http://url-1.com"))
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateImageNotVisible(at: .zero)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])

        sut.simulateImageNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])
    }

    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateImageVisible(at: .zero)
        let view1 = sut.simulateImageVisible(at: 1)

        XCTAssertEqual(view0?.isShowingLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)

        loader.completeImageLoading(at: .zero)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
    }

    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateImageVisible(at: .zero)
        let view1 = sut.simulateImageVisible(at: 1)

        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)

        let imageData0 = UIImage.make(withColor: .red).pngData()!

        loader.completeImageLoading(with: imageData0, at: .zero)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, .none)

        let imageData1 = UIImage.make(withColor: .blue).pngData()!

        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view1?.renderedImage, imageData1)
    }

    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateImageVisible(at: .zero)
        let view1 = sut.simulateImageVisible(at: 1)

        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)

        let imageData0 = UIImage.make(withColor: .red).pngData()!

        loader.completeImageLoading(with: imageData0, at: .zero)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view1?.isShowingRetryAction, true)
    }

    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        let view = sut.simulateImageVisible(at: .zero)

        XCTAssertEqual(view?.isShowingRetryAction, false)

        let invalidImageData = Data("invalid image data".utf8)

        loader.completeImageLoading(with: invalidImageData, at: .zero)
        XCTAssertEqual(view?.isShowingRetryAction, true)
    }

    func test_feedImageViewRetryButton_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        let view0 = sut.simulateImageVisible(at: 0)
        let view1 = sut.simulateImageVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }

    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com"))
        let image1 = makeImage(url: URL(string: "http://url-1.com"))
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateFeedImageNearVisible(at: .zero)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])

        sut.simulateFeedImageNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }

    func test_feedImageView_cancelsImagePreloadingWhenNoLongerNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com"))
        let image1 = makeImage(url: URL(string: "http://url-1.com"))
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateFeedImageNotNearVisible(at: .zero)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])

        sut.simulateFeedImageNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) ->
    (sut: FeedViewController, loader: LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loaderSpy, imageLoader: loaderSpy)
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
        XCTAssertEqual(view?.isShowingLocation ?? false, image.location != nil, file: file, line: line)
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

        var loadedImageURLs: [URL?] {
            imageRequests.map({ $0.url })
        }

        private(set) var cancelledImageURLs = [URL?]()
        private var imageRequests: [(url: URL?, completion: (FeedImageDataLoader.Result) -> Void)] = []

        // MARK: - Feed Image Data LoaderFunctions

        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void
            func cancel() {
                cancelCallBack()
            }
        }

        func loadImageData(from url: URL?, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy(cancelCallBack:  { [weak self] in
                self?.cancelledImageURLs.append(url)
            })
        }

        func cancelImageLoading(for url: URL) {
            cancelledImageURLs.append(url)
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = .zero) {
            imageRequests[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = .zero) {
            imageRequests[index].completion(.failure(XCTestCase.anyError))
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

    var feedImageSection: Int { .zero }

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

    @discardableResult
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let idxPath = IndexPath(row: row, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: idxPath)
    }

    @discardableResult
    func simulateImageVisible(at row: Int) -> FeedImageCell? {
        feedImageView(at: row) as? FeedImageCell
    }

    func simulateImageNotVisible(at row: Int) {
        let view = simulateImageVisible(at: row)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }

    func simulateFeedImageNearVisible(at row: Int) {
        let dataSource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        dataSource?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageNotNearVisible(at row: Int) {
        simulateFeedImageNearVisible(at: row)
        let dataSource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
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

    var isShowingLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }

    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }

    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }

    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
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

private extension UIImage {

    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: .zero, y: .zero, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }

}

private extension UIButton {

    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }
}
