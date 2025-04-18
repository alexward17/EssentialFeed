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
        primary.load(completion: completion)
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
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))

        let sut = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        let exp = expectation(description: "Wait for load completion")

        sut.load { result in
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

    // MARK: - Helpers

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
