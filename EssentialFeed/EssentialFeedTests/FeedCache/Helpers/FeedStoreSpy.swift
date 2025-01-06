//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Alex Ward on 2025-01-06.
//

import Foundation
import EssentialFeed

// MARK: - Spies

class FeedStoreSpy: FeedStore {

    // MARK: - Types

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void

    // MARK: - Properties

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    // MARK: - Helpers

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = .zero) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = .zero) {
        deletionCompletions[index](nil)
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }

    func completeInsertion(with error: Error, at index: Int = .zero) {
        insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = .zero) {
        insertionCompletions[index](nil)
    }

    func completeRetrieval(with error: Error, at index: Int = .zero) {
        retrievalCompletions[index](error)
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }

}
