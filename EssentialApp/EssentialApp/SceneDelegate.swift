import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS
import Combine

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    public var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer.defaultDirectoryURL.appending(
                path: "feed-store.sqlite"
            )
        )
    }()

    private lazy var localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)

    public convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        configureWindow()
    }

    public func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: { _ in })
    }

    public func configureWindow() {
        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer
                .feedComposedWith(
                    feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                    imageLoader: makeLocalImageLoaderWithRemoteFallback
                )
        )
    }

    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        return httpClient
            .getPublisher(from: url).tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .dispatchOnMainQueue()
    }

    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }

}


