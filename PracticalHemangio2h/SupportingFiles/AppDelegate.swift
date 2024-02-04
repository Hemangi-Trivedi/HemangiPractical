//
//  AppDelegate.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 02/02/24.
//

import UIKit
import GoogleSignIn
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        DatabaseManager.shared.createDatabse()
        GIDSignIn.sharedInstance()?.clientID = "938008334884-jqp1ehl5c395hre06a3qs39ul6navus0.apps.googleusercontent.com"

        do {
            try GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            
            if let user = GIDSignIn.sharedInstance()?.currentUser {
                // User is signed in
                print("User is signed in: \(user)")
            } else {
                // User is signed out
                print("User is signed out")
            }
        } catch let error {
            // Handle error
            print("Error occurred: \(error.localizedDescription)")
        }

        
//        GIDSignIn.sharedInstance()!.restorePreviousSignIn { user, error in
//          if error != nil || user == nil {
//            // Show the app's signed-out state.
//          } else {
//            // Show the app's signed-in state.
//          }
//        }
        

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

        handled = GIDSignIn.sharedInstance().handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }
    
}

