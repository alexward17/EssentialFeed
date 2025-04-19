//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Alex Ward on 2025-04-18.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoadSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()

        expect(
            makeSUT(
                primaryResult: .success(primaryFeed),
                fallbackResult: .success(fallbackFeed)),
            toCompleteWith: .success(primaryFeed)
        )
    }

    func test_load_deliversFallbackFeedOnPrimaryLoadFailure() {
        let fallbackFeed = uniqueFeed()

        expect(
            makeSUT(
                primaryResult: .failure(Self.anyNSError),
                fallbackResult: .success(fallbackFeed)),
            toCompleteWith: .success(fallbackFeed)
        )
    }

    func test_load_deliversErrorOnPrimaryAndFallbackFailure() {
        expect(
            makeSUT(
                primaryResult: .failure(Self.anyNSError),
                fallbackResult: .failure(Self.anyNSError)),
            toCompleteWith: .failure(Self.anyNSError)
        )
    }

    // MARK: - Helpers

    private final func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoaderWithFallbackComposite {

        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)

        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)

        return sut
    }

}
