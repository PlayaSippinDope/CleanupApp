//
//  SceneDelegate.swift
//  CleanupApp
//
//  Created by Philip on 14.04.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootViewController = AppAssembly.makeMainScreen()

        window.rootViewController = UINavigationController(rootViewController: rootViewController)
        window.overrideUserInterfaceStyle = .light
        self.window = window
        window.makeKeyAndVisible()
    }
}
