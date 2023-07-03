//
//  LoginViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 4/13/21.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth


class LoginViewController: UIViewController , UITextFieldDelegate{
    

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    //@IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
       super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setUpElements()
        
        
        

        // Do any additional setup after loading the view.
    }
    
    func setUpElements(){
        errorLabel.alpha = 0
        
        Utilities.styleTextField(emailTextField)
        Utilities.styleFilledButton(loginButton)
        Utilities.styleTextField(passwordTextField)
    }
    
    func transitionToOnLocationRequest() {
        let locationRequest = storyboard?.instantiateViewController(identifier: Constants.Storyboard.getUserLocationViewController) as? getUserLocationViewController
        view.window?.rootViewController = locationRequest
        view.window?.makeKeyAndVisible()
    }
    
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    //when the user taps anywhere but the text box the person exits out of keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification:Notification) {
        view.frame.origin.y = -300
    }
    
    
    
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        //validate text fields, make sure the fields are filled in
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { [self] (result, error) in
            if error != nil {
                //Didnt sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                if UserDefaults.standard.bool(forKey: "invitedToGame") == true {
                    
                } else {
                    transitionToHome()
                }
                
                
                
            }
        }
    }
}
