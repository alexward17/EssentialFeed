import Foundation
import EssentialFeed

// MARK: - Spies

class FeedStoreSpy: FeedStore {

    // MARK: - Properties

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    // MARK: - Helpers

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = .zero) {
        deletionCompletions[index](.failure(error))
    }

    func completeDeletionSuccessfully(at index: Int = .zero) {
        deletionCompletions[index](.success(Void()))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }

    func completeInsertion(with error: Error, at index: Int = .zero) {
        insertionCompletions[index](.failure(error))
    }
 
    func completeInsertionSuccessfully(at index: Int = .zero) {
        insertionCompletions[index](.success(Void()))
    }

    func completeRetrieval(with error: Error, at index: Int = .zero) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrievalWithEmptyCache(at index: Int = .zero) {
        retrievalCompletions[index](.success((.none)))
    }

    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = .zero) {
        // make sure the timestamp is less than 7 days old
        retrievalCompletions[index](.success(((CachedFeed(feed: feed, timestamp: timestamp)))))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }

}
