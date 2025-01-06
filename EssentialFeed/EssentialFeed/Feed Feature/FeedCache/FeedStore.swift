//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2025-01-04.
//

import Foundation

public protocol FeedStore {

    // MARK: - Types

    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void

    var retrievedFeedImages: [FeedImage] { get set }

    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    func retrieve(completion: @escaping RetrievalCompletion)

}

