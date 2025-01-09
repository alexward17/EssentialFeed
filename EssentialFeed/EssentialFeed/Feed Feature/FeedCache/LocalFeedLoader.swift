//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2025-01-04.
//

import Foundation

private final class FeedCachePolicy {

    // MARK: - Constants

    private let MAX_CACHE_AGE_IN_DAYS: Int = 7

    // MARK: - Properties

    private let calendar = Calendar(identifier: .gregorian)
    final let currentDate: () -> Date

    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }

    // MARK: - Helpers

    final func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: MAX_CACHE_AGE_IN_DAYS, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }

}

public final class LocalFeedLoader {

    // MARK: - Properties

    private let store: FeedStore
    private let cachePolicy: FeedCachePolicy

    // MARK: - Initializers

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.cachePolicy = FeedCachePolicy(currentDate: currentDate)
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
            feed.toLocal(), timestamp: cachePolicy.currentDate(), completion: { [weak self] cacheInsertionError in
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

            case let .found(feed, timestamp) where cachePolicy.validate(timestamp):
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

            case let .found(_, timestamp) where !cachePolicy.validate(timestamp):
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
