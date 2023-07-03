//
//  phoneNumberAuthViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/23/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import JGProgressHUD

class phoneNumberAuthViewController: UIViewController, UITextFieldDelegate {
    var phonenumber: String! = ""
    let defaults = UserDefaults.standard
    var email: String?
    var password: String?
    let phoneNotVerified = UserDefaults.standard.bool(forKey: "phoneNotVerified")
    let spinner = JGProgressHUD()
    
    
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var smscode: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("value is \(phoneNotVerified)")
        smscode.isHidden = true
        phoneNumberInput.delegate = self
        errorLabel.alpha = 0
        
        // Do any additional setup after loading the view.
    }
    
    func transitionToOnboarding () {
        let onboardingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.atheleteProfileUINavigationViewController) as? atheleteProfileUINavigationViewController
        view.window?.rootViewController = onboardingViewController
        view.window?.makeKeyAndVisible()
    }
    
    var verificationID : String? = nil
    
    
    
    @IBAction func buttonSubmitted(_ sender: Any) {
        
        if phoneNotVerified == true {
            if smscode.isHidden {
                spinner.show(in: view)
                if !phoneNumberInput.text!.isEmpty {
                    
                    Auth.auth().settings?.isAppVerificationDisabledForTesting = false
                    
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberInput.text!, uiDelegate: nil, completion: { verificationID, error in
                        if error != nil {
                            self.spinner.dismiss()
                            print(error.debugDescription)
                        } else {
                            self.spinner.dismiss()
                            self.verificationID = verificationID
                            self.smscode.isHidden = false
                        }
                    })
                } else {
                    errorLabel.alpha = 1
                    self.errorLabel.text = "Please enter your phone number"
                }
            } else {
                if verificationID != nil {
                    spinner.show(in: view)
                    
                    //add the database creation of the user
                    let user = Auth.auth().currentUser
                    

                    
                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID!, verificationCode: self.smscode.text! )
                    
                    user?.updatePhoneNumber(credential, completion: { error in
                        if error != nil {
                            self.spinner.dismiss()
                            self.errorLabel.alpha = 1
                            self.errorLabel.text = error?.localizedDescription
                        } else {
                            self.spinner.dismiss()
                            let userList = userList(uid: user!.uid, displayName: user!.displayName!, email: user!.email!)
                            DatabaseManager.shared.insertUser(with: userList , completion: { success in
                                print("added to database")
                                UserDefaults.standard.setValue(false, forKey:  "phoneNotVerified")
                                self.transitionToOnboarding()
                            })
                            
                        }
                        
                        
                        
                        
                    })
                    
                    
                } else {
                    errorLabel.alpha = 1
                    errorLabel.text = "Error getting verification code"
                    
                }
            
            }
            
        } else {
            
            if smscode.isHidden {
                spinner.show(in: view)
                if !phoneNumberInput.text!.isEmpty {
                    
                    Auth.auth().settings?.isAppVerificationDisabledForTesting = false
                    
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberInput.text!, uiDelegate: nil, completion: { verificationID, error in
                        if error != nil {
                            self.spinner.dismiss()
                            print(error.debugDescription)
                        } else {
                            self.spinner.dismiss()
                            self.verificationID = verificationID
                            self.smscode.isHidden = false
                        }
                    })
                } else {
                    errorLabel.alpha = 1
                    self.errorLabel.text = "Please enter your phone number"
                }
            } else {
                if verificationID != nil {
                    spinner.show(in: view)
                    Auth.auth().signIn(withEmail: email!, password: password!) { AuthDataResult, error in
                        if error != nil {
                            print("email is \(self.email!)")
                            print("password is \(self.password!)")
                            self.spinner.dismiss()
                            self.errorLabel.alpha = 1
                            self.errorLabel.text = error?.localizedDescription
                            
                        } else {
                            //add the database creation of the user
                            let user = Auth.auth().currentUser
                            
                            
                            
                            
                            let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID!, verificationCode: self.smscode.text! )
                            
                            user?.updatePhoneNumber(credential, completion: { error in
                                if error != nil {
                                    self.spinner.dismiss()
                                    self.errorLabel.alpha = 1
                                    self.errorLabel.text = error?.localizedDescription
                                } else {
                                    self.spinner.dismiss()
                                    let userList = userList(uid: user!.uid, displayName: user!.displayName!, email: user!.email!)
                                    DatabaseManager.shared.insertUser(with: userList , completion: { success in
                                        print("added to database")
                                        self.transitionToOnboarding()
                                    })
                                    
                                }
                                
                                
                                
                                
                            })
                        }
                    }
                    
                } else {
                    errorLabel.alpha = 1
                    errorLabel.text = "Error getting verification code"
                    
                }
                
            }
        }
        
        
        
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        guard let text = phoneNumberInput.text else { return }
        phoneNumberInput.text = text.applyPatternOnNumbers(pattern: "+# (###) ###-####", replacementCharacter: "#")
        
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

extension String {
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
