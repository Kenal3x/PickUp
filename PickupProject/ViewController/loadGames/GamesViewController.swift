//
//  GamesViewController.swift
//  PickupProject
//
//  Created by Sharmeen Lalani on 6/5/21.
//

import UIKit
import FirebaseFirestore
import Foundation
import Firebase
import FirebaseAuth
import CoreLocation





class GamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var NoGameLabel: UITableView!
    var publicData: gamePublicData?
    var locationManager: CLLocationManager!
    var currentLocation = CLocationManager.shared.location
    let defaults = UserDefaults.standard
    var userState: String?

    @IBOutlet weak var tableView: UITableView!
    
    

    
    override func viewDidAppear(_ animated: Bool) {
        CLocationManager.shared.start { (info) in
            
        }
    }
    
    
    
    //this is the data for the tables
    var games = [Game]()
    
    var userGames = [Game]()
    var gamesToDisplay = [Game]()
    
    
    func transitionToGetLocation () {
        let getUserlocation = storyboard?.instantiateViewController(identifier: Constants.Storyboard.getUserLocationViewController) as? getUserLocationViewController
        view.window?.rootViewController = getUserlocation
        view.window?.makeKeyAndVisible()
    }

    //old way, requires an old look through document feature
    func filterUserGames() {
        userGames.removeAll()
        let userUID = Auth.auth().currentUser!.uid
        for game in games {
            if game.userMap.contains(where: { (key: String, value: [String : Any]) in
                if key == userUID {
                    return true
                } else {
                    return false
                }
            })
            {
                userGames.append(game)
            }
        }
    }
    
    
    @IBAction func refreshButton(_ sender: Any) {
        if CLocationManager.shared.location == nil {
            print("Location is not updated")
            present(alertMessage.shared.systemLocation(), animated: true)
            
        } else {
            
            DispatchQueue.main.async {
                CLocationManager.shared.start{(info) in
                    
                }
                self.loadGames()
            }
            
     
        }
        
    }
    
   
    func loadGames() {
        //go into firebase get all games initialize them save as games array in line 12
        let db = Firestore.firestore()
        //sets a listener
        self.refreshButton.isEnabled = false
        self.refreshButton.tintColor = UIColor.clear
        db.collection("games").whereField("date", isGreaterThan: Timestamp.init()).whereField("finishedGameCreation", isEqualTo: true).whereField("based", isEqualTo: defaults.string(forKey: "userstate") ?? "")
            .addSnapshotListener { [self] (querySnapshot, err) in
                if let err = err{
                    print(err)
                }
                else {
                    self.games.removeAll()
                    for document in querySnapshot!.documents{
                        
                        let game = Game.init(gameDocument: document.data(), documentID: document.documentID)

                        let meters = game.locationCoordinates.distance(from: currentLocation!)
                        let distanceMiles = ((meters*0.00062137)*10).rounded() / 10
                        
                        //nothing more than 150 miles can be seen on the feed
                        if game.gamePrivate == false {
                            if  distanceMiles < 150{
                                self.games.append(game)
                            }
                        }
                    }
                    
               
                    self.gamesToDisplay = self.games.sorted(by: {$0.locationCoordinates.distance(from: currentLocation!) < $1.locationCoordinates.distance(from: currentLocation!)})
                }
                
                tableView.isHidden = false
                if gamesToDisplay.isEmpty {
                    alertLabel.text = "There are no games in a 100 mile radius"
                    NoGameLabel.isHidden = false
                    if currentLocation == nil {
                        alertLabel.text = "PickUp relies on your location to find PickUp games near you"
                    }
                    tableView.isHidden = true
                }
                self.tableView.reloadData()
            }
        
    }
    
    //not important for you anthony
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesToDisplay.count
    }
    //not very important for you ant
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as? GameTableViewCell else {
                    fatalError("The dequeued cell is not an instance of GameTableViewCell.")
                }

        
        let distanceInMeters = gamesToDisplay[indexPath.row].locationCoordinates.distance(from: currentLocation!)
        let distanceMiles = ((distanceInMeters*0.00062137)*10).rounded() / 10

        cell.distance.text = "Distance \(distanceMiles) miles"
        cell.locationOfGame.text = gamesToDisplay[indexPath.row].title
        
        if gamesToDisplay[indexPath.row].sport == "Soccer" {
            cell.sportOfGame.image = UIImage(named: "soccerAnnotation")
        } else if (gamesToDisplay[indexPath.row].sport == "Basketball") {
            cell.sportOfGame.image = UIImage(named: "basketballAnnotation")
        } else {
            cell.sportOfGame.image = UIImage(named: "footballAnnotation")
        }
        cell.dateOfGame.text = gamesToDisplay[indexPath.row].dateString
        cell.timeOfGame.text = gamesToDisplay[indexPath.row].timeString
        
        
        return cell
    }
    //this is important
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameManager.shared.loadPublicData(gameID: gamesToDisplay[tableView.indexPathForSelectedRow!.row].ID, completion: { (data) in
            self.publicData = data
            self.performSegue(withIdentifier: "gameTapped", sender: self)

        })
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? GameViewController {
            destination.currentGame = gamesToDisplay[(tableView.indexPathForSelectedRow?.row)!]
            destination.publicData = publicData
            
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "GameTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GameTableViewCell" )
        self.tableView.delegate=self
        self.tableView.dataSource=self
       
        currentLocation = CLocationManager.shared.location
        print("This is the user's current location \(currentLocation)")
        
        let userState = self.defaults.string(forKey: "userstate") as? String ?? ""
        
        print("Games view controller locationmanager started")
    
        
        CLocationManager.shared.start { (info) in

            self.currentLocation = CLocationManager.shared.location
        }
    

        DispatchQueue.main.async {
            if CLocationManager.shared.location == nil {
                self.present(alertMessage.shared.systemLocation(), animated: true)
                self.refreshButton.isEnabled = true
                self.refreshButton.tintColor = UIColor.blue
            } else {
                self.refreshButton.isEnabled = false
                self.refreshButton.tintColor = UIColor.white
                self.loadGames()
            }
                
            
        }
        
        
     
        
        
        
        // Do any additional setup after loading the view.
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


