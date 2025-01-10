//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-02.
//

import XCTest
import EssentialFeed

class CacheFeedUseCase: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT(in: self)
        XCTAssertEqual(store.receivedMessages.count, .zero)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT(in: self)
        sut.save(uniqueImageFeed().models) {_ in}
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT(in: self)
        let deletionError = Self.anyError
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }

    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp }, in: self)
        let feed = uniqueImageFeed()
        sut.save(feed.models) {_ in}
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp }, in: self)
        let deletionError = Self.anyError
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }

    func test_save_failsOnInsertionError() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp }, in: self)
        let insertionError = Self.anyError

        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp }, in: self)
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }

    func test_save_doesNotDeliverDeletionErrorWhenAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult?]()
        sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0) })
        sut = nil
        store.completeDeletion(with: Self.anyError)
        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorWhenAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults: [LocalFeedLoader.SaveResult?] = []
        sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0) })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: Self.anyError)
        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers

    private final func expect(_ sut: LocalFeedLoader,
                              toCompleteWithError expectedError: NSError?,
                              when action: () -> Void,
                              file: StaticString = #filePath,
                              line: UInt = #line) {
        let exp = expectation(description: "Completion")

        var receievedError: LocalFeedLoader.SaveResult?
        sut.save(uniqueImageFeed().models) { error in
            receievedError = error
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receievedError as NSError?, expectedError, file: file, line: line)
    }

}
