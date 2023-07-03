//
//  TabViewVC.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/26/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth




class TabViewVC: UITabBarController{
    
    let user = Auth.auth().currentUser



    override func viewDidLoad() {
        
    
        super.viewDidLoad()
//        var ref: DatabaseReference!
//
//
//
//        ref = Database.database().reference()
//        //writes to real time  database that we wanna use for messaging
//        print("This is the default set for firebase dynamic link \(String(describing: UserDefaults.standard.string(forKey: "gameID")))")


        
        Auth.auth().addStateDidChangeListener() { auth, user in
            
            
            if user == nil {
                self.noAccount()
                print("going back")
                
            }
            
            if auth.currentUser?.phoneNumber == nil {
                UserDefaults.standard.setValue(true, forKey: "phoneNotVerified")
                //user did not complete phone number onboarding
                self.noPhoneNumber()
            }
            
        }
        
        
        
        
            
    }
        

        
    
    
    func noAccount(){
        let goToAccount = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginNavViewController) as! loginNavViewController
        
        view.window?.rootViewController = goToAccount
        view.window?.makeKeyAndVisible()
    }
    func noPhoneNumber(){
        let noPhoneNumber = storyboard?.instantiateViewController(identifier: Constants.Storyboard.phoneNumberAuthController) as! phoneNumberAuthViewController
        
        view.window?.rootViewController = noPhoneNumber
        view.window?.makeKeyAndVisible()
    }
    
    
    // Do any additional setup after loading the view.



/*
 // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
