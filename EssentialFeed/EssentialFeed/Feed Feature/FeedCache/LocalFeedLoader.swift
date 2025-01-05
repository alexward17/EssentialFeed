//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2025-01-04.
//

import Foundation

public final class LocalFeedLoader {

    public typealias SaveResult = Error

    // MARK: - Properties

    private let store: FeedStore
    private let currentDate: () -> Date

    // MARK: - Initializers

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    // MARK: - Helpers

    public func save(_ feed: [FeedImage], completion: @escaping ((SaveResult?) -> Void)) {
        store.deleteCachedFeed { [weak self] cacheDeletionError in
            guard let self else { return }
            guard cacheDeletionError == nil else {
                completion(cacheDeletionError)
                return
            }
            cache(feed, with: completion)
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping ((SaveResult?) -> Void)) {
        store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        })
    }

}

public extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    }
}
