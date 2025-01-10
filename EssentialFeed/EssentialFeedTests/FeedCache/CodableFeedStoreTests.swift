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
        clearCacheFromDisk()
    }

    override func tearDown() {
        super.tearDown()
        clearCacheFromDisk()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Await Completion")
        sut.retrieve { result in
            guard case .empty = result else {
                XCTFail("Unexpected Result")
                return
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
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
            sut.retrieve { result in
                guard case let .found(feed, timestamp) = result else {
                    XCTFail("Unexpected Result")
                    return
                }
                XCTAssertEqual(feed, expectedLocalFeed)
                XCTAssertEqual(timestamp, expectedTimestamp)

                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1)
    }

    // MARK: - Test Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        let sut = CodableFeedStore(storeURL: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func clearCacheFromDisk() {
        let storeURL: URL =
             FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
         try? FileManager.default.removeItem(at: storeURL)
    }


}
