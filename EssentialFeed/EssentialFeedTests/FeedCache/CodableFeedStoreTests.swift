//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-10.
// SIDE EFFECTS ARE THE ENEMY OF CONCURRENCY, the less side effects you have, the easier it is to make your app run concurrently

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

    override func setUp() {
        super.setUp()
        clearStoredCacheArtifactsFromDisk()
    }

    override func tearDown() {
        super.tearDown()
        clearStoredCacheArtifactsFromDisk()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        let expectedLocalFeed = uniqueImageFeed().local
        let expectedTimestamp = Date()
        insert((expectedLocalFeed, expectedTimestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: expectedLocalFeed, timestamp: expectedTimestamp))
    }

    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedLocalFeed = uniqueImageFeed().local
        let expectedTimestamp = Date()

        insert((expectedLocalFeed, expectedTimestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: expectedLocalFeed, timestamp: expectedTimestamp))
    }

    func test_retrieve_deliversErrorOnRetrievalError() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        let expectedError = Self.anyError

        try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)

        expect(sut, toRetrieve: .failure(expectedError))
    }

    func test_retrieve_hasNoSideEffectOnRetrievalError() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        let expectedError = Self.anyError

        try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(expectedError))
    }

    func test_insert_overridesPreviousyInsertedCache() {
        let sut = makeSUT()

        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")

        let latestImageFeed = uniqueImageFeed().local
        let latestTimestamp = Date()

        let latestInsertionError = insert((latestImageFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")

        expect(sut, toRetrieve: .found(feed: latestImageFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(fileURLWithPath: "/invalid/store")
        let timestamp = Date()
        let sut = makeSUT(storeURL: invalidStoreURL)

        let insertionError = insert((feed: uniqueImageFeed().local, timestamp: timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected to receive an error")
    }

    func test_insert_hasNoSideEffectsInsertionError() {
        let invalidStoreURL = URL(fileURLWithPath: "/invalid/store")
        let timestamp = Date()
        let sut = makeSUT(storeURL: invalidStoreURL)
        insert((feed: uniqueImageFeed().local, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .empty)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected to receive no error")

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        let insertionError = insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)
        XCTAssertNil(insertionError)

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expect non-empty cache deletion to succeed")

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let invalidStoreURL = noDeletePermissionURL
        let sut = makeSUT(storeURL: invalidStoreURL)

        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected deletion to fail")
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let invalidStoreURL = noDeletePermissionURL
        let sut = makeSUT(storeURL: invalidStoreURL)
        let expectedFeed = uniqueImageFeed().local
        let expectedTimestamp = Date()
        insert((feed: expectedFeed, timestamp: expectedTimestamp), to: sut)
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperations = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")

        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")

        sut.deleteCachedFeed { _ in
            completedOperations.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")

        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertEqual(completedOperations, [op1, op2, op3], "expected operations to run serially")
    }

    // MARK: - Test Helpers

    private var testSpecificStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableFeedStoreTests.self)).store")
    }

    private var noDeletePermissionURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {

        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func clearStoredCacheArtifactsFromDisk() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
