import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public typealias DeletionResult = Result<Void, Error>
public typealias DeletionCompletion = (DeletionResult) -> Void

public typealias InsertionResult = Result<Void, Error>
public typealias InsertionCompletion = (InsertionResult) -> Void

public typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
public typealias RetrievalCompletion = (RetrievalResult) -> Void

public protocol FeedStore {

    // MARK: - Types

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
