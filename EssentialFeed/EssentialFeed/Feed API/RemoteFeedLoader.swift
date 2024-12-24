import Foundation

public final class RemoteFeedLoader: FeedLoader {

    // MARK: - Types

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

   public typealias Result = LoadFeedResult

    // MARK: - Properties

    private final let url: URL
    private final let client: HTTPClient

    // MARK: - Initializers

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    // MARK: - Loading Functions

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemMapper.map(data, response))
            case .failure(let error):
                completion(.failure(Error.connectivity))
            }
        })
    }

}
