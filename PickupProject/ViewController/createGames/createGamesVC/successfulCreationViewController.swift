//
//  successfulCreationViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/18/21.
//

import UIKit
import Lottie


class successfulCreationViewController: UIViewController {
    var gameID: String?

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
    
    
    private func presentShareSheet(with url: String) {
        
        let shareSheetVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(shareSheetVC, animated: true)
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
        
        guard let gameID = gameID else {return}
        //let linkParameter = URL(string: "https://www.projectpickup.app/games?GameID=\(gameID)")
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.projectpickup.app"
        components.path = "/games"
        
        let gameIDQueryItem = URLQueryItem(name: "gameID" , value: gameID)
        components.queryItems = [gameIDQueryItem]
        
        guard let linkParameter = components.url else {return}
        print("It is printing this \(linkParameter)")
    }

    
    
    
    
}
