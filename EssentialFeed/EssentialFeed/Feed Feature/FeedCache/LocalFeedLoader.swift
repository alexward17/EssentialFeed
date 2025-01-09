//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2025-01-04.
//

import Foundation

public final class LocalFeedLoader {

    // MARK: - Properties

    private let store: FeedStore
    private let currentDate: () -> Date

    // MARK: - Initializers

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

}

extension LocalFeedLoader {
    public typealias SaveResult = Error

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
        store.insert(
            feed.toLocal(), timestamp: currentDate(), completion: { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping ((LoadResult) -> Void)) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, againts: currentDate()):
                completion(.success(feed.toModels()))

            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in }

            case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, againts: currentDate()):
                store.deleteCachedFeed { _ in }

            case .empty, .found: break
            }
        }
    }
}

public extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    }
}

public extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    }
}
