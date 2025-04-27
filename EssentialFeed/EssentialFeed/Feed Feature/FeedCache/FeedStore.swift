import Foundation

public protocol FeedStore {

    // MARK: - Types

    typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    // MARK: - Functions

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible for dispatching to appropriate threads if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible for dispatching to appropriate threads if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    /// The completion handler can be invoked on any thread.
    /// Clients are responsible for dispatching to appropriate threads if needed.
    func retrieve(completion: @escaping RetrievalCompletion)

}
