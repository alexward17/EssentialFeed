//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-10.
//

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStore: FeedStore {

    // MARK: - Types

    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
    }

    struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }

        init(from local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }
    }

    // MARK: - Properties

    private var storeURL: URL

    // MARK: - Initializer

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    // MARK: - Helpers

    func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion) {
            do {
                let encoder = JSONEncoder()
                let codableFeed = feed.map(CodableFeedImage.init)
                let encodedValues = try encoder.encode(Cache(feed: codableFeed, timestamp: timestamp))
                try encodedValues.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }

    func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }

        do {
            let cache = try JSONDecoder().decode(Cache.self, from: data)
            let localImages = cache.feed.map({
                $0.local
            })
            completion(.found(feed: localImages, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }

        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }

}

class CodableFeedStoreTests: XCTestCase {

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

    // MARK: - Test Helpers

    private var testSpecificStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableFeedStoreTests.self)).store")
    }

    private var noDeletePermissionURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }

    @discardableResult private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Await Completion")

        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        return insertionError
    }

    @discardableResult private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Await Completion")

        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        return deletionError
    }

    private func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    private func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {

            case (.empty, .empty),
                (.failure, .failure):
                break

            case let (.found(feed: expectedFeed, timestamp: expectedTimestamp),
                      .found(feed: retrievedFeed, timestamp: retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)

            default:
                XCTFail("Unexpected result: \(retrievedResult)", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
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
