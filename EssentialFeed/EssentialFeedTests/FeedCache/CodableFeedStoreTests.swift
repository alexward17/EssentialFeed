//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-10.
//

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStore {

    // MARK: - Types

    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    typealias InsertionCompletion = (Error?) -> Void

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
            let encoder = JSONEncoder()
            let codableFeed = feed.map(CodableFeedImage.init)
            guard let encodedValues = try? encoder.encode(Cache(feed: codableFeed, timestamp: timestamp)) else {
                return
            }
            try! encodedValues.write(to: storeURL)
            completion(nil)
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL),
              let cache = try? JSONDecoder().decode(Cache.self, from: data) else {
            completion(.empty)
            return
        }
        let localImages = cache.feed.map({
            $0.local
        })
        completion(.found(feed: localImages, timestamp: cache.timestamp))

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

        let exp = expectation(description: "Await Completion")

        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default: XCTFail("Unexpected Result")
                }
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_retrieve_afterInsertingToEmptyCacheDeliversInsertedValues() {
        let sut = makeSUT()

        let expectedLocalFeed = uniqueImageFeed().local
        let expectedTimestamp = Date()
        let exp = expectation(description: "Await Completion")

        sut.insert(expectedLocalFeed, timestamp: expectedTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Unexpected Error")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        expect(sut, toRetrieve: .found(feed: expectedLocalFeed, timestamp: expectedTimestamp))
    }

    func test_retrieve_asNoSideEffectWhenCacheHasStoredData() {
        let sut = makeSUT()

        let expectedLocalFeed = uniqueImageFeed().local
        let expectedTimestamp = Date()
        let exp = expectation(description: "Await Completion")

        sut.insert(expectedLocalFeed, timestamp: expectedTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Unexpected Error")
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in

                    switch (firstResult, secondResult) {
                    case let (.found(feed: firstFeed, timestamp: firstTimestamp),
                              .found(feed: secondFeed, timestamp: secondTimestamp)):
                        XCTAssertEqual(firstFeed, expectedLocalFeed)
                        XCTAssertEqual(firstTimestamp, expectedTimestamp)

                        XCTAssertEqual(secondFeed, expectedLocalFeed)
                        XCTAssertEqual(secondTimestamp, expectedTimestamp)
                        exp.fulfill()
                    default:
                        XCTFail("Unexpected Result")
                    }
                }

            }
        }

        wait(for: [exp], timeout: 1)
    }

    // MARK: - Test Helpers

    let testSpecificStoreURL: URL =
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableFeedStoreTests.self)).store")

    private func expect(
        _ sut: CodableFeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {

            case (.empty, .empty):
                break

            case let (.found(feed: expectedFeed, timestamp: expectedTimestamp),
                      .found(feed: retrievedFeed, timestamp: retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)

            default: XCTFail("Unexpected result: \(retrievedResult)", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {

        let sut = CodableFeedStore(storeURL: testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func clearStoredCacheArtifactsFromDisk() {
         try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
