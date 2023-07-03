//
//  additionalInfoViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/1/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class additionalInfoViewController: UIViewController {
    
    @IBOutlet weak var sportLevelTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var sportTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var legalStuff: UILabel!
    @IBOutlet weak var state: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    var statePickerView = UIPickerView()
    var genderPickerview = UIPickerView()
    var sportPickerView = UIPickerView()
    var sportLevelPickerView = UIPickerView()
    var legalAgree: Bool?
    @IBOutlet weak var agreeToLegal: UISwitch!
    
    let genders = ["Male" , "Female", "Other", "Prefer not to Say"]
    let sports = ["Soccer" , "Basketball" , "Football"]
    let sportsLevel = ["Rookie" , "Intermediate" , "Pro-Am" ]
    let states = [ "AK","AL","AR","AS","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","UT","VA","VI","VT","WA","WI","WV","WY"]


    
    let user = Auth.auth().currentUser
    

    @IBAction func userAcceptance(_ sender: UISwitch) {
        if (sender.isOn == true) {
            legalAgree = true
        } else {
            legalAgree = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //leads to the terms and conditions
        errorLabel.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(additionalInfoViewController.legalLinkTap))
    
        
        legalStuff.isUserInteractionEnabled = true
        legalStuff.addGestureRecognizer(tap)
        
        
        genderPickerview.delegate = self
        genderPickerview.dataSource = self
    
        sportPickerView.delegate = self
        sportPickerView.dataSource = self
        
        sportLevelPickerView.delegate = self
        sportLevelPickerView.dataSource = self
        
        statePickerView.delegate = self
        statePickerView.dataSource = self
        
        genderTextField.inputView = genderPickerview
        sportTextField.inputView = sportPickerView
        sportLevelTextField.inputView = sportLevelPickerView
        state.inputView = statePickerView
        
        genderTextField.placeholder = "Gender"
        sportTextField.placeholder = "Sport"
        sportLevelTextField.placeholder = "Sport Level"
        state.placeholder = "State"
        
        genderPickerview.tag = 1
        sportPickerView.tag = 2
        sportLevelPickerView.tag = 3
        statePickerView.tag = 4

        // Do any additional setup after loading the view.
    }
    
    func checkFields ()-> String? {
        if genderTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            sportTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            sportLevelTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)  == "" || state.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "please fill in all fields"
        }
        
        if legalAgree == nil || legalAgree == false {
            return "Please read terms and conditions"
        }
        
        return nil
    }
    
    @IBAction func legalLinkTap(sender: UITapGestureRecognizer){
        UIApplication.shared.open(URL(string: "https://www.projectpickup.app/terms-and-conditions")!)
    }
    
    
    
    @IBAction func nextButtonIsPressed(_ sender: Any) {
        print("Button is being pressed")
        let error = checkFields()
        let db = Firestore.firestore()
        if error != nil {
            errorLabel.text = error
            errorLabel.alpha = 1
        } else {
            let gender = genderTextField.text ?? ""
            let sport = sportTextField.text ?? ""
            let sportLevel  = sportLevelTextField.text ?? ""
            
            
            
            db.collection("users").document(user!.uid).setData(["userVerified" : true , "gender" : gender , "sport" : sport , "sportLevel" : sportLevel , "state" : state!.text , "userAgreeWithLegal" : legalAgree! , "onboardingComplete" : true], merge: true)
            
            
            UserDefaults.standard.setValue(true, forKey: "completedSignUp")
            if UserDefaults.standard.bool(forKey: "invitedToGame") == true {
                //checks if user got a invite link
                invitedToGame()
            } else {
                performSegue(withIdentifier: "additionalInfoToUserLocation" , sender: self)
            }
            
        }
        

        
        
    }
    
    
    
    func invitedToGame() {
        let gameID = UserDefaults.standard.string(forKey: "upcomingGameID")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
        guard let gameViewController = storyboard.instantiateViewController(identifier: "gameViewController") as? GameViewController else {return}
        let db = Firestore.firestore()
        db.collection("games").document(gameID!).getDocument{ (document, error) in
            if error != nil {
                print("There has been an error getting data for dynamic link game data: \(String(describing: error?.localizedDescription))")
            }
            if let document = document , document.exists {
                let game = Game.init(gameDocument: document.data()!, documentID: document.documentID)
                db.collection("publicGameDoc").document(gameID!).getDocument{ (document, error) in
                    if error != nil {
                        print("There has been an error with getting publicData for dynamic link data: \(error?.localizedDescription)")
                    }
                
                    
                    
                    if let document = document , document.exists {
                        gameViewController.currentGame = game
                        gameViewController.invite = true
                        self.view.window?.rootViewController = gameViewController
                        
                    
                        //recives data for the game, and public data
                        print("It reached here")
                        
                    }
                }
            }
        }
    }
    


}


extension additionalInfoViewController: UIPickerViewDataSource , UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return genders.count
        case 2:
            return sports.count
        case 3:
            return sportsLevel.count
        case 4:
            return states.count
        default:
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return genders[row]
        case 2:
            return sports[row]
        case 3:
            return sportsLevel[row]
        case 4:
            return states[row]
        default:
            return "Data not Found"
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            genderTextField.text =  genders[row]
            genderTextField.resignFirstResponder()
        case 2:
            sportTextField.text = sports[row]
            sportTextField.resignFirstResponder()
        case 3:
            sportLevelTextField.text = sportsLevel[row]
            sportLevelTextField.resignFirstResponder()
        case 4:
            state.text = states[row]
            state.resignFirstResponder()
        default:
            sportLevelTextField.text = ""
            sportTextField.resignFirstResponder()
            
        }
        
    }
}
