//
//  AppDelegate.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/12.
//
import UIKit
import FirebaseCore
import GoogleSignIn
import IQKeyboardManagerSwift
import FirebaseCrashlytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            print("Invalid URL")
            return false
        }

        print("components:\(components)")

        guard let deepLink = DeepLink(rawValue: host) else {
            print("Deeplink not found: \(host)")
            return false
        }

        if let tabBarController = SceneDelegate.window?.rootViewController as? TabBarViewController {
            tabBarController.handleDeepLink(deepLink)
        }

        var handled: Bool

        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }

        // Handle other custom URL types.

        // If not handled by this app, return false.
        return false
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = -34
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
          if error != nil || user == nil {
            // Show the app's signed-out state.
          } else {
            // Show the app's signed-in state.
          }
        }
        FirebaseApp.configure()
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


enum DeepLink: String {
    case home
    case scan
}

extension TabBarViewController {
    func handleDeepLink (_ deepLink: DeepLink) {
        switch deepLink {
        case .home:
            present(TabBarViewController(), animated: true)
        case .scan:
            selectedIndex = 3
        }
    }
}
