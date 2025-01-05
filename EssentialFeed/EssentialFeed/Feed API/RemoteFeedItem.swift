//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Alex Ward on 2025-01-05.
//

import Foundation

internal struct RemoteFeedItem: Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL

    public init(id: UUID, description: String? = nil, location: String? = nil, image: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
}
