//
//  welcomeViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/1/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class welcomeViewController: UIViewController {
    
    
    
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var progressButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().currentUser?.reload(completion: { Error in
            if Error != nil {
                print("There has been an error")
            }
            let user = Auth.auth().currentUser
            print("This is the display name \(user?.displayName)")
            self.displayName.text = user?.displayName
            
            
        })
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "welcomeToExtra", sender: self)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
