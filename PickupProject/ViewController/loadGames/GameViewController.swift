//
//  GameViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/12/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleMobileAds


class GameViewController: UIViewController, UITextViewDelegate {
    let userUID = Auth.auth().currentUser?.uid
    var currentGame: Game?
    var invite: Bool?

    let db = Firestore.firestore()
    private var interstitial: GADInterstitialAd?
    @IBOutlet weak var locatioName: UILabel!
    @IBOutlet weak var nameOfGame: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var locationOfGame: UITextView!
    @IBOutlet weak var descriptionGame: UITextView!
   
    @IBOutlet weak var goHome: UIButton!
    @IBOutlet weak var timeOfGame: UITextView!
    @IBOutlet weak var userListLabel: UIButton!
    
    @IBOutlet weak var sportOfGamePicture: UIImageView!
    @IBOutlet weak var sportOfGame: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goHome.alpha = 0
        
        
        
        if ((currentGame?.userMap.contains(where: { (key: String, value: [String : Any]) in
            if key == userUID {
                return true
            } else {
                return false
            }
        })) != nil)
        {
            userButton.setTitle("Leave Game", for: UIControl.State.normal)
        }
        
        if invite == true {
            goHome.alpha = 1
            if user?.uid == nil {
                userButton.setTitle("Create an Account", for: UIControl.State.normal)
            }
            
        }
        
        
        Utilities.styleTitleLabel(nameOfGame)
        
        self.userListLabel.setTitle("User List \((currentGame?.userList.count)) / \(self.currentGame!.amountOfPlayers)", for: UIControl.State.normal)
        self.locatioName.text = currentGame?.title
        self.nameOfGame.text = "\(self.currentGame?.nameOfGame ?? "")"
        self.timeOfGame.text = "\(String(describing: self.currentGame!.dateString)), \(String(describing: self.currentGame!.timeString)) "
        self.locationOfGame.isScrollEnabled = false
        self.locationOfGame.text = self.currentGame?.address.fullAddress ?? ""
        self.descriptionGame.isScrollEnabled = false
        self.descriptionGame.text = self.currentGame?.description ?? ""
        self.sportOfGame.text = self.currentGame?.sport
        
        
        if currentGame?.ownerBall == false {
            sportOfGame.text = ""
        } else {
            
        }
        if  currentGame?.sport == "Soccer" {
            
            self.sportOfGamePicture.image = UIImage(named: "soccerAnnotation")
        } else if currentGame!.sport == "Basketball" {
            self.sportOfGamePicture.image = UIImage(named: "basketballAnnotation")
        } else {
            self.sportOfGamePicture.image = UIImage(named: "footballAnnotation")
        }
    }
    
 
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! userListViewController
        destinationVC.currentGame  = currentGame
    }
    
    @IBAction func reportGame(_ sender: Any) {
        showReport()
    }
    func showReport() {
        let alert = UIAlertController(title: "Reporting \(currentGame!.nameOfGame)", message: "What will you be reporting this game for?" , preferredStyle: .actionSheet )
        
        alert.addAction(UIAlertAction(title: "Explicit Name/Bio", style: .default, handler: {action in
            DatabaseManager.shared.flagGame(with: self.currentGame!.ID, ownerOfGameID: self.currentGame!.ownerID, reason: "ExplicitContent", completion: {result in
                switch result {
                case .success(let reportID):
                    let view = alertMessage.shared.successAlert(with: "Your report has been recorded", messageString: "Report ID: \(reportID)")
                    self.present(view, animated: true, completion: nil)
                    
                case .failure(_):
                    print("there has been an error")
                }
            })
        }))
    
        alert.addAction(UIAlertAction(title: "Racial / Insensitive content", style: .default, handler: {action in
            DatabaseManager.shared.flagGame(with: self.currentGame!.ID, ownerOfGameID: self.currentGame!.ownerID, reason: "InsensitiveContent", completion: {result in
                switch result {
                case .success(let reportID):
                    let view = alertMessage.shared.successAlert(with: "Your report has been recorded", messageString: "Report ID: \(reportID)")
                    self.present(view, animated: true, completion: nil)
                    
                case .failure(_):
                    print("there has been an error")
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Suspicious or Unrelated to Pickup", style: .default, handler: { result in
            DatabaseManager.shared.flagGame(with: self.currentGame!.ID, ownerOfGameID: self.currentGame!.ownerID, reason: "Suspicious", completion: {result in
                switch result {
                case .success(let reportID):
                    let view = alertMessage.shared.successAlert(with: "Your report has been recorded", messageString: "Report ID: \(reportID)")
                    self.present(view, animated: true, completion: nil)
                    
                case .failure(_):
                    print("there has been an error")
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            print("it has been dismissed")
        }))
        
        present(alert, animated: true)
    }
    
    
    func showAlert() {
        let alert = UIAlertController(title: "Deletion", message: "If you leave this game, you are going to be deleting it", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
            self.deleteGame()
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            print("it has been dismissed")
        }))
        
        present(alert, animated: true)
    }
    
    func getBall(gameDocID: String){
        if currentGame?.ownerBall == true{
           print("Owner has a ball")
        } else {
            if currentGame?.ballID == "" {
                DispatchQueue.main.async {
                    print("owner doesnt have a ball")
                    let alert = UIAlertController(title: "Alert", message: "No one as of now is bringing a ball,  will you be bringing a ball?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
                        print("dismissed")
                    }))
                    
                    alert .addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                        self.db.collection("publicGameDoc").document(gameDocID).setData(["ballID": user!.uid] , merge: true , completion: { (error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            }
                            self.transitionToHome()
                        })

                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                print("Someone has already inputted their id")
            }
            
        }
    }
    
    @IBAction func showUserList(_ sender: Any) {
        if user?.uid == nil {
            alertMessage.shared.successAlert(with: "ATTENTION", messageString: "You need to create an account in order to look at users")
        } else {
            performSegue(withIdentifier: "userListShow", sender: self)
        }
        
    }
    
    
    
    @IBAction func goHomePressed(_ sender: Any) {
        transitionToHome()
    }
    
    func addUser() {
        print("It goes through here")
        let user = Auth.auth().currentUser
        if currentGame?.userList.count == currentGame?.amountOfPlayers{
            
            print("amount of users in game \(String(describing: currentGame?.userList.count)) - \(String(describing: currentGame?.amountOfPlayers))")
            print("if statement is not working")
            //checks if the amount of players ahs been reached and returns an error, if the user cannot join anymore
            alertMessage.shared.successAlert(with: "The limit has been reached", messageString: "Please try to find another game to go to")
        } else {
            
            //gets user data
            userData.sharedInstance.getUserData(userID: user!.uid, completion: { (userData) in
                
                
                //joins the game, game gets added to user's upcoming games list.
                gameManager.shared.joinGame(gameDocID: self.currentGame!.ID, userData: userData)
                self.getBall(gameDocID: self.currentGame!.ID)
               
                
            })
        
        }
    }
    
    func deleteUser(){
        //deletes the user from the game's list of players
        
        if currentGame?.ballID != user?.uid {
            db.collection("publicGameDoc").document(currentGame!.ID).updateData(["userList."+userUID! : FieldValue.delete()
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                    
                } else {
                    print("Document successfully updated")
                    
                    
                    
                    self.transitionToHome()
                }
            }
        } else {
            
            //this deletes the user if the user has inputted that he will be bringing the ball
            db.collection("publicGameDoc").document(currentGame!.ID).updateData(["userList."+userUID! : FieldValue.delete() , "ballID" : FieldValue.delete()
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                    
                } else {
                    print("Document successfully updated")
                    
                    self.transitionToHome()
                }
            }
        }
        
    }
    
    func deleteGame() {
        if user?.uid == currentGame?.ownerID {
            db.collection("games").document(currentGame!.ID).delete()
            transitionToHome()
        } else {
            print("You are not the user to be deleting games")
        }
    }

    
    
    //join game is tapped

    @IBAction func buttonTapped(_ sender: Any) {
        
        checkForAccount()

        if currentGame!.userMap.contains(where: { (key: String, value: [String : Any]) in
            if key == userUID {
                return true
            } else {
                return false
            }
        })
        
        
        
        //if the user is already part of the list of players, then the user is prompted to leave if he or she wants to.
        {
            if user?.uid == currentGame?.ownerID {
                showAlert()
            }
            else {
                
                //deletes the user from the game's list of players
                
                deleteUser()
            }
                
            
    //if the user is not in the list of users for the game then the button will allow the user to join
        } else {
            
            addUser()
            getBall(gameDocID: currentGame!.ID)
            
        }
        
        
        //set data and merge is needed in order for the data not to be overwritten
           
    }
}



extension GameViewController {
    func noAccount(){
        let goToAccount = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginNavViewController) as! loginNavViewController
        
        view.window?.rootViewController = goToAccount
        view.window?.makeKeyAndVisible()
    }
    
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    func noPhoneNumber(){
        let noPhoneNumber = storyboard?.instantiateViewController(identifier: Constants.Storyboard.phoneNumberAuthController) as! phoneNumberAuthViewController
        
        view.window?.rootViewController = noPhoneNumber
        view.window?.makeKeyAndVisible()
    }
    
    func checkForAccount() {
        if user?.uid == nil {
            if user?.phoneNumber == nil {
                alertMessage.shared.successAlert(with: "Your phone number has not be verified", messageString: "YOu need to verify your phone number in order to continue")
                saveGameData()
                noPhoneNumber()
            }
            
            alertMessage.shared.successAlert(with: "You have no account", messageString: "You will have to create an account in order to join this game")
            saveGameData()
            noAccount()
        }
        func saveGameData() {
            UserDefaults.resetStandardUserDefaults()
            UserDefaults.standard.set(currentGame?.ID, forKey: "upcomingGameID")
            UserDefaults.standard.set(true , forKey: "invitedToGame")
            
        }
    }
    
}
