//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2025-01-04.
//

import Foundation

public class LocalFeedLoader {

    // MARK: - Properties

    private let store: FeedStore
    private let currentDate: () -> Date

    // MARK: - Initializers

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    // MARK: - Helpers

    public func save(_ items: [FeedItem], completion: @escaping ((Error?) -> Void)) {
        store.deleteCachedFeed { [weak self] cacheDeletionError in
            guard let self else { return }
            guard cacheDeletionError == nil else {
                completion(cacheDeletionError)
                return
            }
            cache(items, with: completion)
        }
    }

    private func cache(_ items: [FeedItem], with completion: @escaping ((Error?) -> Void)) {
        store.insert(items, timestamp: currentDate(), completion: { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        })
    }

}
