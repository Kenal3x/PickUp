//
//  SceneDelegate.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 4/13/21.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseDynamicLinks
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
      return application(app, open: url,
                         sourceApplication: options[UIApplication.OpenURLOptionsKey
                           .sourceApplication] as? String,
                         annotation: "")
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
      if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // ...
        return true
      }
      return false
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        //Statements checks if user is logged in
        
        							
        if user?.uid != nil {
            //if user is logged in, then dynamic link can get sparsed
            if let incomingURL = userActivity.webpageURL {
                print("Incoming URL is \(incomingURL)")
                let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink , error) in
                    guard error == nil else {
                        print("Found an error ! \(error?.localizedDescription)")
                        return
                    }
                    if let dynamicLink = dynamicLink {
                        
                    
                    }
                }
            }
        } else {
            //user.uid returns nil meanning no account
            //gotta parse the incoming dynamic link

            print("There is no account")
            UserDefaults.standard.setValue(true, forKey: "invitedToGame")
            print("Userdefault value has been set to true")
            
        }
        
        
    }
    
    
    
    
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
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

