import Foundation

public final class RemoteImageCommentsLoader {

    // MARK: - Types

    public typealias Result = Swift.Result<[ImageComment], Swift.Error>

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

    public func load(completion: @escaping (RemoteImageCommentsLoader.Result) -> Void) {
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

    private static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteImageCommentsLoader.Result {
        do {
            let items = try ImageCommentsMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }

}
