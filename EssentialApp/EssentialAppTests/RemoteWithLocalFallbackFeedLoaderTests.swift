//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Alex Ward on 2025-04-18.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        })
    }


    // MARK: - Properties

    final let primary: FeedLoader
    final let fallback: FeedLoader

    // MARK: - Initializers

    init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primary = primaryLoader
        self.fallback = fallbackLoader
    }

}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoadSuccess() {

        let exp = expectation(description: "Wait for load completion")
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()

        makeSUT(
            primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed)
        ).load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)

            case .failure:
                XCTFail("Expected successful load feed result, for \(result) instead.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_load_deliversFallbackFeedOnPrimaryLoadFailure() {

        let exp = expectation(description: "Wait for load completion")
        let fallbackFeed = uniqueFeed()

        makeSUT(
            primaryResult: .failure(Self.anyNSError), fallbackResult: .success(fallbackFeed)
        ).load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, fallbackFeed)

            case .failure:
                XCTFail("Expected successful load fallback feed result, for \(result) instead.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers

    private final func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoaderWithFallbackComposite {

        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)

        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)

        return sut
    }

    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance, "Instance should have been deallocated. pottential memory leak",
                file: #filePath,
                line: #line
            )
        }
    }

    static var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }


    private final func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }

    private final class LoaderStub: FeedLoader {

        // MARK: - Properties

        private final let result: FeedLoader.Result

        // MARK: - Initializers

        init(result: FeedLoader.Result) {
            self.result = result
        }

        // MARK: - Helper Functions

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }

}
