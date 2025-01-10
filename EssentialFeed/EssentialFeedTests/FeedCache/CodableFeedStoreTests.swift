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

    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {

        let sut = CodableFeedStore()

        let exp = expectation(description: "Await Completion")
        sut.retrieve { result in
            guard case .empty = result else {
                XCTFail("Unexpected Result")
                return
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)
    }

}
