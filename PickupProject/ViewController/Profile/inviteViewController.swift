//
//  inviteViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 9/10/21.
//

import UIKit
import Lottie
import FirebaseFirestore
import FirebaseDynamicLinks
import JGProgressHUD

class inviteViewController:UIViewController {
    var game: Game?
    let spinner = JGProgressHUD()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    @IBAction func goBackToHomeTapped(_ sender: Any) {
        transitionToHome()
    }

    
    
    private func presentShareSheet(with url: URL) {
        let promoText = "Come join me in an upcomnig pickup!"
        let shareSheetVC = UIActivityViewController(activityItems: [promoText,url], applicationActivities: nil)
        present(shareSheetVC, animated: true)
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
        spinner.show(in: view)
        
        
        guard let gameID = game?.gameID else {return}
        print("This is the gameID being used")
        //let linkParameter = URL(string: "https://www.projectpickup.app/games?GameID=\(gameID)")
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.projectpickup.app"
        components.path = "/games"
        
        let gameIDQueryItem = URLQueryItem(name: "gameID" , value: game?.gameID)
        components.queryItems = [gameIDQueryItem]
        
        guard let linkParameter = components.url else {return}
        let domain = "https://projectpickup.page.link"
        guard let linkBuilder = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: domain) else {
            return
        }
        if let myBundleId = Bundle.main.bundleIdentifier {
            linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        // 2
        linkBuilder.iOSParameters?.appStoreID = Constants.appInfo.appstoreID
        
        
        // 3
        linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder.socialMetaTagParameters?.title = "\(String(describing: user!.displayName!)) has invited you to \(String(describing: game!.placeAddress.nameOfPlace))"
        linkBuilder.socialMetaTagParameters?.descriptionText = "\(String(describing: game?.sport))"
        linkBuilder.socialMetaTagParameters?.imageURL = URL(string: Constants.appInfo.appLogoURL)!

        DynamicLinks.performDiagnostics(completion: nil)
        guard let longURL = linkBuilder.url else { return }
        linkBuilder.shorten { [weak self] url, warnings, error in
          if let error = error {
            print("Oh no! Got an error! \(error)")
            return
          }
          if let warnings = warnings {
            for warning in warnings {
              print("Warning: \(warning)")
            }
          }
          guard let url = url else { return }
          print("I have a short url to share! \(url.absoluteString)")
            self?.spinner.dismiss()

            self?.presentShareSheet(with: url)
        }
        print("The long dynamic link is \(longURL.absoluteString)")
    }

    
    
    
    
}
