//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Alex Ward on 2025-01-12.
//
// Integrate all cache module objects and see how they behave when collaborating

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        setupEmptyStoreState()
    }

    override func tearDown() {
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toLoad: [])
    }

    func test_load_deliversItemsSavedOnSeparateInstances() {
        let saveSUT = makeSUT()
        let loadSUT = makeSUT()
        let expectedFeed = uniqueImageFeed().models

        save(expectedFeed, with: saveSUT)
        expect(loadSUT, toLoad: expectedFeed)
    }

    func test_save_overridesItemsSavedOnASeparateInstance() {
        let saveSUT = makeSUT()
        let overrideSUT = makeSUT()
        let loadSUT = makeSUT()

        let feedToOverride = uniqueImageFeed().models
        let latesFeed = uniqueImageFeed().models + uniqueImageFeed().models

        save(feedToOverride, with: saveSUT)
        save(latesFeed, with: overrideSUT)
        expect(loadSUT, toLoad: latesFeed)
    }

    // MARK: Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { saveResult in
            switch saveResult {
            case let .failure(saveError):
                XCTFail("Expected successful save result, got \(saveError) instead", file: file, line: line)
            default: break 
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)

            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    // In Integration Test, we prefer to use a stack of production instances, with no test doubles
    // This includes a physical file URL to make sure we can create and load the CoreData SQLite artifacts to disk, which can slow down the tests
    // In Unit/Isolated Tests, we prefer to run operations in-memory when possible, which should be ultra-fast.
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), url: XCTestCase.mockURL)
    }

    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        return (feed, feed.toLocal())
    }

}
