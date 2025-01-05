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

internal final class FeedItemMapper {

    private struct GetFeedItemsResponse: Decodable {
        let items: [RemoteFeedItem]
    }

    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == HTTPStatusCode.OK_200(),
              let itemsResponse = try? JSONDecoder().decode(GetFeedItemsResponse.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return itemsResponse.items
    }

}
