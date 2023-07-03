//
//  ViewController.swift
//  asdasd
//
//  Created by Ken Alexopoulos on 4/13/21.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore



class ViewController: UIViewController {


    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CLocationManager.shared.start { (info) in
            
        }
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            
            /* this is used for signing out
             do {
            
                   try Auth.auth().signOut()
               } catch let error {
                   // handle error here
                   print("Error trying to sign out of Firebase: \(error.localizedDescription)")
               } */
            if user != nil {
                self.transitionToHome()

            }
            
            self.setUpElements()
            
        }
        
        //add an else if when we create verificaiton
        
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedSignUp(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    @IBAction func tappedLogin(_ sender: Any) {
        performSegue(withIdentifier: "goToLogin", sender: self)
        
    }
    
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func setUpElements() {
        Utilities.styleHollowButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }


}

