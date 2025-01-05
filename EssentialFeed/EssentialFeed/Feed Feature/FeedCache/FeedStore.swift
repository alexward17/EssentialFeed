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

    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)

}

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL

    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }

    public init?(entity: FeedItemEntity) {
        self.id = UUID(uuidString: entity.id) ?? UUID()
        self.description = entity.description
        self.location = entity.location
        guard let url = URL(string: entity.image) else {
            return nil
        }
        self.imageURL = url
    }
}

