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

        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)

        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)

        return sut
    }

    private func expect(
        _ sut: FeedLoader,
        toCompleteWith expectedResult: FeedLoader.Result,
        file: StaticString = #file, line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
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
