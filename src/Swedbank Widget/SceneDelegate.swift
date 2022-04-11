//
//  SceneDelegate.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2019-12-28.
//  Copyright © 2019 Samuel Ivarsson. All rights reserved.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        checkOpenedFromURL(urlContexts: connectionOptions.urlContexts)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        checkOpenedFromURL(urlContexts: URLContexts)
    }
    
    private func checkOpenedFromURL(urlContexts: Set<UIOpenURLContext>) {
        guard let firstURLContext = urlContexts.first else {
            return
        }
        let urlComponent = URLComponents(url: firstURLContext.url, resolvingAgainstBaseURL: false)!
        if urlComponent.scheme == "com.samuelivarsson.Swedbank-Widget" {
            let kind: String = urlComponent.host ?? ""
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
//            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                exit(0)
//            }
            return
        }
        if let queryItems = urlComponent.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "update" && queryItem.value == "true" {
                    print("reloading...")
                    WidgetCenter.shared.reloadAllTimelines()
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
//                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        exit(0)
//                    }
                }
                if queryItem.name == "sourceApplication" && queryItem.value == "bankid" {
                    print("was lauched by url...")
                    wasLaunchedByURL = true
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

