import UIKit
import EssentialFeediOS

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
        refreshController?.view = mockRefresh
    }

    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }

    @discardableResult
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
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

    func renderedFeedImageData(at index: Int) -> Data? {
        simulateImageVisible(at: 0)?.renderedImage
    }

}
