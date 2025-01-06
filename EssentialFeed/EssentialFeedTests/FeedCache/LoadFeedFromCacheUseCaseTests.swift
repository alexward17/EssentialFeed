//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-06.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load {_ in}

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = Self.anyError
        var receivedError: Error?

        let exp = expectation(description: "Wait for Completion")
        sut.load { result in
            guard case let .failure(error) = result else {
                XCTFail("Should have failed")
                return
            }
            receivedError = error
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)

        wait(for: [exp], timeout: 5)

        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedImages = [FeedImage]()

        let exp = expectation(description: "Wait for Completion")
        sut.load { result in
            guard case let .success(images) = result else {
                XCTFail("Should have succeeded")
                return
            }
            receivedImages = images
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyCache()

        wait(for: [exp], timeout: 5)

        XCTAssertEqual(receivedImages, [])
    }

    func test_load_deliversImagesOnLoadFromCache() {
        let (sut, store) = makeSUT()
        var receivedImages = [FeedImage]()
        let retrievedImages = uniqueImageFeed().models
        let exp = expectation(description: "Wait for Completion")
        sut.load { result in
            guard case let .success(images) = result else {
                XCTFail("Should have succeeded")
                return
            }
            receivedImages = images
            exp.fulfill()
        }

        store.completeRetrieval(with: retrievedImages)

        wait(for: [exp], timeout: 5)

        XCTAssertEqual(receivedImages, retrievedImages)
    }

    // MARK: Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), url: Self.mockURL)
    }

    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        return (feed, feed.toLocal())
    }

}
