//
//  AppDelegate.swift
//  EssentialApp
//
//  Created by Alex Ward on 2025-04-12.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.

        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)

#if DEBUG
        configuration.delegateClass = DebuggingSceneDelegate.self
#endif

        return configuration
    }



}

