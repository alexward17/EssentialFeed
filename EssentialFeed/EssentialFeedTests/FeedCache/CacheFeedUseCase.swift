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

    // MARK: - Initializers

    init(store: FeedStore) {
        self.store = store
    }

    // MARK: - Helpers

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }

}

class FeedStore {

    // MARK: - Properties

    var deleteCachedFeedCount = 0
    var insertCallCount = 0

    // MARK: - Helpers

    func deleteCachedFeed() {
        deleteCachedFeedCount += 1
    }

    func completeDeletion(with error: Error, at index: Int = .zero) {

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

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), imageURL: Self.mockURL)
    }

}
