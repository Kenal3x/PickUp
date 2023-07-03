//
//  AppDelegate.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 4/13/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseDynamicLinks
import GoogleMobileAds

@UIApplicationMain
	class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        notificationsManager.shared.requestAuthorization()
        FirebaseApp.configure()
        

        DynamicLinks.performDiagnostics(completion: nil)
        
        
        return true
    }
  
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
        guard let url = dynamicLink.url else {
            print("There is no dynamic link being sent")
            return
        }
        
        print("Incoming Link parameter is \(url.absoluteString)")
      
        
    
    }

    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { dynamicLink , error in
            print("a link is beign passed")
            if let dynamicLink = dynamicLink {
                self.handleIncomingDynamicLink(dynamicLink)
            }
            
        }
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink , error) in
                guard error == nil else {
                    print("Found an error ! \(error?.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity , restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink , error) in
                guard error == nil else {
                    print("Found an error ! \(error?.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber  = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this methtd to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
      return application(app, open: url,
                         sourceApplication: options[UIApplication.OpenURLOptionsKey
                           .sourceApplication] as? String,
                         annotation: "")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
        print("A link is being detected")
      if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
        print("This is the detected DynamicLink\(dynamicLink)")
        handleIncomingDynamicLink(dynamicLink)
        return true
        
      } else {
        //doesnt work
      return false
    }


}
}

