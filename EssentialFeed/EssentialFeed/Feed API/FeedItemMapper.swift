import Foundation

final class FeedItemMapper {

    private struct GetFeedItemsResponse: Decodable {
        let items: [FeedItemEntity]
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == HTTPStatusCode.OK_200(),
              let itemsResponse = try? JSONDecoder().decode(GetFeedItemsResponse.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(itemsResponse.items.map({ FeedItem(entity: $0) }).compactMap({$0}))
    }
}
