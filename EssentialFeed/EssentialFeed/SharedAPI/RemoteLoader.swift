import Foundation

public final class RemoteLoader<Resource> {

    // MARK: - Types

    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    public typealias Result = Swift.Result<Resource, Swift.Error>

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    // MARK: - Properties

    private final let url: URL
    private final let client: HTTPClient
    private final let mapper: Mapper

    // MARK: - Initializers

    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }

    // MARK: - Loading Functions

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success((data, response)):
                completion(map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }

    private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do { return .success(try mapper(data, response)) }
        catch { return .failure(Error.invalidData) }
    }

}
