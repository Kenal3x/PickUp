//
//  CreateGameViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/16/21.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore
import FirebaseAuth



//for the uiPicker

//user profile
let user = Auth.auth().currentUser

class CreateGameViewController: UIViewController, UITextFieldDelegate {
    
    let sports = ["Soccer" , "Basketball" , "Football" , "Spikeball" , "Lacrosse" , "Tennis" , "Badminton" , "Working Out" , "Running" , "Gym"]
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var descriptionOfGame: UITextField!
    @IBOutlet weak var nameOfGame: UITextField!
    @IBOutlet weak var locationOfGame: UITextField!
    
    @IBOutlet weak var dateOfGame: UIDatePicker!

    var sportsChoosen: String!
    var nameOfPlace: String!
    var Address: Address?
    var finalSportChoosen: String!
    var idDocument: String!
    var userState: String?
    
    
    var coordinate: CLLocationCoordinate2D!
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeZone = .none
        return dateFormatter
    }
    
    @IBOutlet weak var sportPickerView: UIPickerView!
    
    
    func setUpUI () {
        Utilities.styleTextField(nameOfGame)
        Utilities.styleTextField(descriptionOfGame)
        Utilities.styleTextField(locationOfGame)
        Utilities.styleImportantButton(createGameButton)
        dateOfGame.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
    }
    
    func showError( message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
   }
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionOfGame.delegate = self
        errorLabel.alpha = 0
        userState = defaults.string(forKey: "userstate")
        print("this is the user state \(userState ?? "")")
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if Address?.fullAddress == ""{}else
        {
            locationOfGame.text = Address?.fullAddress
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameFilters" {
            let destinationVC = segue.destination as! CreateGamesFilterViewController
            destinationVC.documentID = idDocument
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
        
        sportPickerView.delegate = self
        sportPickerView.dataSource = self
        
        
    
    }
    
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = descriptionOfGame.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
            
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count < 40
    }
    
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    //checks the fields still needs to work on this
    func checkFields() -> String?{
        if nameOfGame.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            descriptionOfGame.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            locationOfGame.text?.trimmingCharacters(in: .whitespacesAndNewlines)  == "" {
            return "Please fill in all fields"
        }
        return nil
    }
    
    
    // defaults to soccer if nothing is picekd.

    
    
    
   
    //taps create Game Button
    @IBAction func tapp(_ sender: Any) {
        
        //check fields runs and checks if all the data is present
        let error = checkFields()
        
        if error != nil {
            //something wrong with the fields so you give
            showError(message: error!)
        }
        else {
            
            //Gets data from fields
            let nameGame = nameOfGame.text!
            let description = descriptionOfGame.text!
            let sport = sportsChoosen
            let gameDate = dateOfGame.date
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            db.collection("users").document(user!.uid).getDocument { [self] document, error in
                if error != nil {
                    print(error?.localizedDescription)
                }
                if let document = document , document.exists {
                    
                    //document exists
                    
                    let userData = User.init(userDocument: document.data()!, documentID: document.documentID)
                    
                    
                    
                    //creates the game
                    
       
                    ref = db.collection("games").addDocument(data: [ "gameID": ref?.documentID,
                                                                     "geoHash" : GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude) ,
                                                                     "latitude" : coordinate.latitude ,
                                                                     "longtitude": coordinate.longitude,
                                                                     "placeID" : "",
                                                                     "placeAddress" : ["street" : Address?.street , "city" : Address?.city , "postalCode" : Address?.postal_code , "fullAddress" : Address?.fullAddress,"nameOfPlace" : Address?.nameOfPlace , "country": Address?.country],
                                                                     "nameOfGame": nameOfGame,
                                                                     "descriptionOfGame": descriptionOfGame,
                                                                     "finishedGameCreation": false,
                                                                     "dateCreated": FieldValue.serverTimestamp(),
                                                                     "date" : gameDate,
                                                                         "userList" : [ user!.uid : ["displayName" : user?.displayName , "role" : "owner" , "ppURL" : user?.photoURL?.absoluteString]]
                                                                         
                                                         ]) { [self] ( error) in
                            
                            if error != nil {
                                self.showError(message: "There was an errror")
                            }
                            
                        
                            
                            self.idDocument = ref!.documentID
                            print(self.idDocument!)
                            print("game is created with no data in upcoming games for user")
                                                        
                            self.performSegue(withIdentifier: "gameFilters", sender: self)
                        }
                    
                    
                    
                    
                }
            }
            
        
            
        }
        
        
    }
    
    
    
    
    
        //when location button is pressed, it will segue to finding location, if there is text in it it will not segue
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func locationTapped(_ sender: Any) {
        if locationOfGame.text ==  "" {
            performSegue(withIdentifier: "searchShow", sender: self)
        }
    }
    
    
   
    //unwind function that MapViewController calls in order to come back
    @IBAction func unwindToCreateGame (sender: UIStoryboardSegue){}
    
}

extension CreateGameViewController: UIPickerViewDelegate,  UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sports.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sports[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        finalSportChoosen = sports[row]
    }
    
}
