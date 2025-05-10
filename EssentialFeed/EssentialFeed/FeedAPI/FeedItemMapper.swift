import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items.map({ .init(remoteItem: $0) })
    }
}

public struct RemoteFeedItem: Codable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL

    public init(id: UUID, description: String? = nil, location: String? = nil, image: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
}
