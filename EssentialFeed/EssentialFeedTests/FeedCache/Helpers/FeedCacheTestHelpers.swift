//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-07.
//

import Foundation
import EssentialFeed
import XCTest

func makeSUT(currentDate: @escaping () -> Date = Date.init,
             in testCase: XCTestCase,
             file: StaticString = #filePath,
             line: UInt = #line) -> (sut: LocalFeedLoader,
                                     store: FeedStoreSpy
             ) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    testCase.trackForMemoryLeaks(store, file: file, line: line)
    testCase.trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
}

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), url: XCTestCase.mockURL)
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    return (feed, feed.toLocal())
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }

    func minusFeedCacheMaxAge() -> Date {
        adding(days: -FeedCachePolicy.MAX_CACHE_AGE_IN_DAYS)
    }
}
