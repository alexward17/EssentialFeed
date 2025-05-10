import Foundation

public final class RemoteFeedLoader: FeedLoader {

    // MARK: - Types

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    // MARK: - Properties

    private final let url: URL
    private final let client: HTTPClient

    // MARK: - Initializers

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    // MARK: - Loading Functions

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(Self.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }

    private static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }

}
