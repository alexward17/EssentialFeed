import Foundation
import Combine

final class FeedViewModel {

    // MARK: - Types

    typealias StateSubject<T> = PassthroughSubject<T, Never>
    typealias Observer<T> = (T) -> Void

    // MARK: - Properties

    private final var feedLoader: FeedLoader
    final var onLoadingStateChange: Observer<Bool>?
    final var onFeedLoad: Observer<[FeedImage]>?

    // MARK: - Initializers

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    final func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            self?.onLoadingStateChange?(false)

            guard let self, let feed = try? result.get() else { return }

            onLoadingStateChange?(false)
            onFeedLoad?(feed)
        }
    }

}
