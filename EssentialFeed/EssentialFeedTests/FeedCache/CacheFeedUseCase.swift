//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-02.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {

    // MARK: - Properties

    private let store: FeedStore
    private let currentDate: () -> Date

    // MARK: - Initializers

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    // MARK: - Helpers

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            guard error == nil else { return }
            store.insert(items, timestamp: currentDate())
        }
    }

}

class FeedStore {

    // MARK: - Types

    typealias DeletionCompletion = (Error?) -> Void

    // MARK: - Properties

    var deleteCachedFeedCount = 0
    var insertCallCount = 0
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    private var deletionCompletions = [DeletionCompletion]()

    // MARK: - Helpers

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCount += 1
        deletionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = .zero) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = .zero) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date) {
        insertCallCount += 1
        insertions.append((items: items, timestamp: timestamp))
    }

}

class CacheFeedUseCase: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCount, .zero)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCount, 1)
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        let deletionError = Self.anyError
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.insertCallCount, .zero)
    }

    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertCallCount, 1)
    }

    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), imageURL: Self.mockURL)
    }

}
