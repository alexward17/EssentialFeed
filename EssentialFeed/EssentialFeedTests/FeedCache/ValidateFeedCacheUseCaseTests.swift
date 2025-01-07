//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-07.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT(in: self)
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT(in: self)
        let retrievalError = Self.anyError

        sut.validateCache()
        store.completeRetrieval(with: retrievalError)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT(in: self)

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_doesNotDeleteLessThan7DaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date.init()
        let lessThan7DaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate }, in: self)

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: lessThan7DaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deletes7DaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date.init()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate }, in: self)

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validateCache_deletesMoreThan7DaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date.init()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate }, in: self)

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

}
