import Foundation

public class CodableFeedStore: FeedStore {

    // MARK: - Types

    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
    }

    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }

        init(from local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }
    }

    // MARK: - Properties

    private var storeURL: URL

    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)

    // MARK: - Initializer

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    // MARK: - Helpers

    public func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion) {
            let storeURL = self.storeURL

            queue.async(flags: .barrier) {
                do {
                    let encoder = JSONEncoder()
                    let codableFeed = feed.map(CodableFeedImage.init)
                    let encodedValues = try encoder.encode(Cache(feed: codableFeed, timestamp: timestamp))
                    try encodedValues.write(to: storeURL)
                    completion(.success(Void()))
                } catch {
                    completion(.failure(error))
                }
            }
        }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL

            queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                completion(.success(.none))
                return
            }

            do {
                let cache = try JSONDecoder().decode(Cache.self, from: data)
                let localImages = cache.feed.map({
                    $0.local
                })
                completion(.success((CachedFeed(feed: localImages, timestamp: cache.timestamp))))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL

        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return
            }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(Void()))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
