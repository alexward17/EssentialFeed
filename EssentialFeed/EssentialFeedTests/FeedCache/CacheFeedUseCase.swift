//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-02.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {

    // MARK: - Properties

    let store: FeedStore

    // MARK: - Initializers

    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {

    // MARK: - Properties

    var deleteCachedFeedCount = 0
}

class CacheFeedUseCase: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCount, .zero)
    }

}
