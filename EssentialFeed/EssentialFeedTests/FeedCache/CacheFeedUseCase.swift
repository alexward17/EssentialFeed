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

    func save(_ items: [FeedItem], completion: @escaping ((Error?) -> Void)) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            guard error == nil else {
                completion(error)
                return
            }
            store.insert(items, timestamp: currentDate(), completion: { [weak self] error in
                guard let self else { return }
                completion(error)
            })
        }
    }

}

protocol FeedStore {

    // MARK: - Types

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)

}

class CacheFeedUseCase: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages.count, .zero)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) {_ in}
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = Self.anyError
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }

    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) {_ in}
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let deletionError = Self.anyError
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }

    func test_save_failsOnInsertionError() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let insertionError = Self.anyError

        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }

    func test_save_doesNotDeliverDeletionErrorWhenAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults: [Error?] = []
        sut?.save([uniqueItem()], completion: { receivedResults.append($0) })
        sut = nil
        store.completeDeletion(with: Self.anyError)
        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorWhenAfterSUTInstanceIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults: [Error?] = []
        sut?.save([uniqueItem()], completion: { receivedResults.append($0) })
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

        var receievedError: Error?
        sut.save([uniqueItem()]) { error in
            receievedError = error
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receievedError as NSError?, expectedError, file: file, line: line)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), imageURL: Self.mockURL)
    }

    // MARK: - Spy

    private class FeedStoreSpy: FeedStore {

        // MARK: - Types

        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void

        // MARK: - Properties

        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }

        private(set) var receivedMessages = [ReceivedMessage]()
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()

        // MARK: - Helpers

        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }

        func completeDeletion(with error: Error, at index: Int = .zero) {
            deletionCompletions[index](error)
        }

        func completeDeletionSuccessfully(at index: Int = .zero) {
            deletionCompletions[index](nil)
        }

        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }

        func completeInsertion(with error: Error, at index: Int = .zero) {
            insertionCompletions[index](error)
        }

        func completeInsertionSuccessfully(at index: Int = .zero) {
            insertionCompletions[index](nil)
        }

    }

}
