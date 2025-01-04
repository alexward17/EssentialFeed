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

    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)

}
