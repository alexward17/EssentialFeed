
// SIDE EFFECTS ARE THE ENEMY OF CONCURRENCY, the less side effects you have, the easier it is to make your app run concurrently

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

    override func setUp() {
        super.setUp()
        clearStoredCacheArtifactsFromDisk()
    }

    override func tearDown() {
        super.tearDown()
        clearStoredCacheArtifactsFromDisk()
    }

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

    func test_retrieve_deliversErrorOnRetrievalError() {
        try! "invalid data".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)
        assertThatRetrieveDeliversFailureOnRetrievalError(on: makeSUT())
    }

    func test_retrieve_hasNoSideEffectOnRetrievalError() {
        try! "invalid data".write(to: testSpecificStoreURL, atomically: false, encoding: .utf8)
        assertThatRetrieveHasNoSideEffectsOnFailure(on: makeSUT())
    }

    func test_insert_overridesPreviousyInsertedCache() {
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: makeSUT())
    }

    func test_insert_deliversErrorOnInsertionError() {
        let sut = makeSUT(storeURL: noPermissionURL)
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }

    func test_insert_hasNoSideEffectsInsertionError() {
        let sut = makeSUT(storeURL: noPermissionURL)
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: makeSUT())
    }

    func test_delete_deliversErrorOnDeletionError() {
        let invalidStoreURL = noPermissionURL
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let invalidStoreURL = noPermissionURL
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }

    func test_storeSideEffects_runSerially() {
        assertThatSideEffectsRunSerially(on: makeSUT())
    }

    // MARK: - Test Helpers

    private var testSpecificStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableFeedStoreTests.self)).store")
    }

    private var noPermissionURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {

        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func clearStoredCacheArtifactsFromDisk() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }

}
