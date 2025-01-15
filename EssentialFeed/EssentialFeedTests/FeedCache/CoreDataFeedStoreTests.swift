//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-12.
//

import Foundation
import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: makeSUT())
    }

    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: makeSUT())
    }

    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: makeSUT())
    }

    func test_insert_overridesPreviousyInsertedCache() {
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: makeSUT())
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: makeSUT())
    }

    func test_storeSideEffects_runSerially() {
        assertThatSideEffectsRunSerially(on: makeSUT())
    }

    // MARK: - Test Helpers

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)

        // Writing to "dev/null" device discards all data written to it, but reports write operation success
        // The writes are ignored but CoreData still works with the in-memory object graph
        // Alternitavely, you can create a CoreData stack with an in-memory persistent store configuration for the tests

        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

}

