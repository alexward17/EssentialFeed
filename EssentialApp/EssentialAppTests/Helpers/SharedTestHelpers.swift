//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Alex Ward on 2025-04-19.
//
import Foundation
import EssentialFeed
import XCTest

extension XCTestCase {


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


    static var anyURL: URL {
        URL(string: "http://any-url.com")!
    }

    static var anyData: Data {
        Data("any data".utf8)
    }

    final func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }

    func expect(
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

}


final class FeedLoaderStub: FeedLoader {

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
