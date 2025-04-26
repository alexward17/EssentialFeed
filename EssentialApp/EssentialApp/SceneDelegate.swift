//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Alex Ward on 2025-04-12.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let session = URLSession(configuration: .ephemeral)
      //  let client = URLSessionHTTPClient(session: session)

        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)

        let localStoreURL = NSPersistentContainer.defaultDirectoryURL.appending(path: "feed-store.sqlite")

        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)

        window?.rootViewController = FeedUIComposer
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
    }

    private func makeRemoteClient() -> HTTPClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {

        case "offline":
            return AlwaysFailingHTTPClient()
        default: return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        }
    }

}

private class AlwaysFailingHTTPClient: HTTPClient {

    private class Task: HTTPClientTask { func cancel(){} }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
    

}

