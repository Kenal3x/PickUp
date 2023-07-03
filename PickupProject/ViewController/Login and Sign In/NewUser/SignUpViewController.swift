//
//  SignUpViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 4/13/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth



class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var checkPassword: UITextField!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    var inputtedPhoneNumber: String? = ""
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeZone = .none
        return dateFormatter
    }
    
    override func viewWillLayoutSubviews() {
        setUpElements()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    //find age from Date of Birt
    
    
    //sets up styling of the page
    func setUpElements(){
        errorLabel.alpha = 0
        
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(emailTextField)
        
        
        Utilities.styleFilledButton(signUpButton)
    }
    
    //error message
    func showError( message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func transitionToOnboarding () {
        let onboardingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.atheleteProfileUINavigationViewController) as? atheleteProfileUINavigationViewController
        view.window?.rootViewController = onboardingViewController
        view.window?.makeKeyAndVisible()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let phoneVC = segue.destination as? phoneNumberAuthViewController else { return }
        phoneVC.email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        phoneVC.password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    //check fields, and sees that data is correct and works when input.
    func validateFields () -> String? {
        // check that fields are filled in
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)  == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "please fill in all fields"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedRepeatPassword = checkPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure you make a password that is atleast 8 characters long, contains special a capital letter and a number"
        }
        if cleanedRepeatPassword != cleanedPassword {
            return "Your password input does not match"
        }
        
        return nil
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //this sets the display Name
    func setDisplayName(firstName: String , lastName:String) {
        let user = Auth.auth().currentUser
        print(user?.uid)
        let changeRequest = user?.createProfileChangeRequest()
        let displayName = "\(firstName) \(lastName)"
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { (error) in
            if error != nil {
                print("something went wrong")
            } else {
                print(user?.displayName)
            }
        }
    }
    
    
    //when signup button is tapped"
    @IBAction func signUpTapped(_ sender: Any) {
        
        let error = validateFields()
        
        if error != nil {
            //something wrong with the fields so you give
            showError(message: error!)
        }
        else {
            //create cleaned versions of data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //still need to make an error statement
            
            print("It made it through here")
            
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    //There was an error in creating the user
                    self.showError(message: "Error creating user")
                    
                }
                else {
                    
                    let displayName = "\(firstName) \(lastName)"
                    self.setDisplayName(firstName: firstName, lastName: lastName)
                    
                    //User was created succesfully, now store data
                    let db = Firestore.firestore()
                    
                    //sets the username
                    
                    
                    db.collection("users")
                        .document(result!.user.uid)
                        .setData(["firstname" : firstName ,
                                  "lastname" : lastName,
                                  "displayName" : displayName,
                                  "uid" : result!.user.uid ,
                                  "email" : email,
                                  "imageURL" : "",
                                  "created": FieldValue.serverTimestamp()])
                        { (error) in
                            //if there is an error
                            if error != nil {
                                self.showError(message: "Error in saving user data")
                            }
                            // i sign out and sign in in order for display name to refresh, literally I tried everything
                            let firebaseAuth = Auth.auth()
                            do {
                                try firebaseAuth.signOut()
                            } catch let signOutError as NSError {
                                print("Error signing out: %@", signOutError)
                            }
                            UserDefaults.standard.setValue(false, forKey: "phoneNotVerified")
                            
                            
                            self.performSegue(withIdentifier: "goVerify", sender: self)
                            
                            
                            UserDefaults.standard.setValue(false, forKey: "completedSignUp")
                            
                            
                            
                            
                        }
                }
                
            }
            
        }
    }
    
}


