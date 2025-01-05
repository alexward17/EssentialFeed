import Foundation

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
