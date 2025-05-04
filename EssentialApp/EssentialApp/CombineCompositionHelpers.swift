import Combine
import EssentialFeed
import Foundation

public extension FeedImageDataLoader {

    typealias Publisher = AnyPublisher<Data, Error>

    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?

        return Deferred {
            Future { promise in
                task = self.loadImageData(from: url, completion: promise)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }

}

public extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        })
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch{ _ in fallbackPublisher()}.eraseToAnyPublisher()
    }
}

public extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url, completion: { _ in })
    }
}


public extension FeedLoader {

    typealias Publisher = AnyPublisher<[FeedImage], Error>

    func loadPublisher() -> Publisher {
        // Futures are eager publishers that fire as soon as they are created.
        // Wrapping the Future in a Deferred publishers ensures its execution will be delayed until it is subscribed to.
        Deferred { Future(self.load) }.eraseToAnyPublisher()
    }

}

public extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == [FeedImage] {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch{ _ in fallbackPublisher()}.eraseToAnyPublisher()
    }

}

public extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

public extension DispatchQueue {

    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler()
    }

    struct ImmediateWhenOnMainQueueScheduler: Scheduler {

        public typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType

        public typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        public var now: SchedulerTimeType {
            DispatchQueue.main.now
        }

        public var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            action()
        }

        public func schedule(
            after date: SchedulerTimeType,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void
        ) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        public func schedule(
            after date: SchedulerTimeType,
            interval: SchedulerTimeType.Stride,
            tolerance: SchedulerTimeType.Stride,
            options: SchedulerOptions?,
            _ action: @escaping () -> Void) -> any Cancellable {
                DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
            }

    }
}
