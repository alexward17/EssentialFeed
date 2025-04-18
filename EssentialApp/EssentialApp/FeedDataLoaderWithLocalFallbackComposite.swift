import EssentialFeed
import Foundation

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {

    // MARK: - Properties

    final let primary: FeedImageDataLoader
    final let fallback: FeedImageDataLoader

    // MARK: - Initializers

    public init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primary = primaryLoader
        self.fallback = fallbackLoader
    }

    // MARK: - Helpers

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        let task = TaskWrapper()

        task.wrapped = primary.loadImageData(from: url, completion: { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        })

        return task
    }

    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?

        func cancel() {
            wrapped?.cancel()
        }
    }

}
