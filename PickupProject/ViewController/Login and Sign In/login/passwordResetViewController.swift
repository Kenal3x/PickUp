//
//  passwordResetViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/30/21.
//

import UIKit
import FirebaseAuth

class passwordResetViewController: UIViewController {

    @IBOutlet weak var emailTextInput: UITextField!
    
    @IBOutlet weak var passwordSent: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordSent.alpha = 0
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        let email = emailTextInput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                self.passwordSent.text = error?.localizedDescription
            }
            
            self.passwordSent.alpha = 1
        }
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
