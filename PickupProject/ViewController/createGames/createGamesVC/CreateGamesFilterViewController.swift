//
//  createGamesFilterViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/17/21.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseFirestore

class CreateGamesFilterViewController: UIViewController{
  
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var ballSegementControl: UISegmentedControl!
    @IBOutlet weak var privacySegmentControl: UISegmentedControl!
    @IBOutlet weak var amountOfPlayersTextField: UITextField!
    @IBOutlet weak var levelOfPlayTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    let amountOfPlayers = ["2" , "4" , "6" , "8" , "10", "12" , "14", "16" , "18" , "20" , "22"]
    let levelOfPlayers = ["Intermediate" , "Pro-Am"]
    let ageGroup = ["Youth (16-18)" , "Adults (18+)"]
    let gender = ["Men" , "Women" , "Coed"]
    
    var amountOfPlayersPickerView = UIPickerView()
    var levelOfPlayPickerView = UIPickerView()
    var ageGroupPickerView  = UIPickerView()
    var genderPickerView = UIPickerView()
    
    
    var documentID: String!
    var ownerBall: Bool!
    var gamePrivate: Bool!
 
    @IBAction func ballAvailability(_ sender: UISegmentedControl) {
        switch ballSegementControl.selectedSegmentIndex{
        case 0:
            ownerBall = true
        case 1:
            ownerBall = false
        default:
            break
        }
    }

    
    @IBAction func privacySetting(_ sender: UISegmentedControl) {
        switch privacySegmentControl.selectedSegmentIndex {
        case 0:
            gamePrivate = true
        case 1:
            gamePrivate = false
        default:
            break
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! successfulCreationViewController
        destinationViewController.gameID = documentID
        
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let error = checkFields()
        if checkFields() != nil {
            showError(message: error!)
        }
        else {
            let db = Firestore.firestore()
            let batch = db.batch()

            print(documentID)
            
            let gameRef = db.collection("games").document(documentID)
            
            batch.setData(["ownerBall": ownerBall ?? true,
                                                                 "gamePrivate" : false,
                                                                 "gender" : genderTextField.text ?? "male",
                                                                 "levelOfPlay" : levelOfPlayTextField.text ?? "Intermediate",

                                                                 "amountOfPlayers" : Int(amountOfPlayersTextField.text!) ?? 0,
                                                                 "finishedGameCreation" : true], forDocument: gameRef, merge: true)
            let gameDocRef = db.collection("games").document(documentID)
            if ownerBall == false {
                batch.setData(["ballID" : "" ], forDocument: gameDocRef, merge: true)
            } else {
                
                batch.setData(["ballID" : user!.uid], forDocument: gameDocRef, merge: true)
            }
            batch.commit()  { err in
                if let err = err {
                    print("There was an error \(err)")
                } else {
                    self.transitionToHome()
                }
            }
            
            
        }
        
    }
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    
    
    
    func setUpView() {
        errorLabel.alpha = 0
        amountOfPlayersTextField.inputView = amountOfPlayersPickerView
        levelOfPlayTextField.inputView = levelOfPlayPickerView
        genderTextField.inputView = genderPickerView
        
        amountOfPlayersPickerView.delegate = self
        levelOfPlayPickerView.delegate = self
        ageGroupPickerView.delegate  = self
        genderPickerView.delegate = self
        amountOfPlayersPickerView.dataSource = self
        levelOfPlayPickerView.dataSource = self
        ageGroupPickerView.dataSource  = self
        genderPickerView.dataSource = self
        
        
        amountOfPlayersPickerView.tag = 1
        levelOfPlayPickerView.tag = 2
        ageGroupPickerView.tag  = 3
        genderPickerView.tag = 4
    
    }
    
    func checkFields() -> String?{
        if amountOfPlayersTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            levelOfPlayTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            genderTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all Fields"
        }
        
        return nil
        
    }
    
}




extension CreateGamesFilterViewController: UIPickerViewDataSource , UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return amountOfPlayers.count
        case 2:
            return levelOfPlayers.count
        case 4:
            return gender.count
            
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return amountOfPlayers[row]
        case 2:
            return levelOfPlayers[row]
        case 4:
            return gender[row]
            
        default:
            return "data not found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            amountOfPlayersTextField.text = amountOfPlayers[row]
            amountOfPlayersTextField.resignFirstResponder()
    
        case 2:
            levelOfPlayTextField.text = levelOfPlayers[row]
            levelOfPlayTextField.resignFirstResponder()
        case 4:
            genderTextField.text =  gender[row]
            genderTextField.resignFirstResponder()
        default:
            return
        }
    
    }
    
}
