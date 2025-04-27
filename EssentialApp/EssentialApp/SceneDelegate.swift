import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let localStoreURL = NSPersistentContainer.defaultDirectoryURL.appending(path: "feed-store.sqlite")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        configureWindow()
    }

    func configureWindow() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        //  let session = URLSession(configuration: .ephemeral)
        //  let client = URLSessionHTTPClient(session: session)

        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)

        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)

        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer
            .feedComposedWith(
                feedLoader: FeedLoaderWithFallbackComposite(
                    primaryLoader: FeedLoaderCacheDecorator(
                        decoratee: remoteFeedLoader,
                        cache: localFeedLoader
                    ),
                    fallbackLoader: localFeedLoader
                ),
                imageLoader: FeedImageDataLoaderWithFallbackComposite(
                    primaryLoader: localImageLoader,
                    fallbackLoader: FeedImageDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader
                    )
                )
            )
        )
    }

    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

}

