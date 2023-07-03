//
//  ViewController.swift
//  JustSmallTHings
//
//  Created by Ken Alexopoulos on 8/9/22.
//

import UIKit
import FirebaseFirestore
import CoreLocation
import FirebaseFirestore
import Foundation
import FirebaseAuth



class gamesViewController: UIViewController ,UICollectionViewDelegate , UICollectionViewDataSource {
    
    let defaults = UserDefaults.standard
    let userID = Auth.auth().currentUser!.uid
    var userState: String?
    var locationManager: CLLocationManager!
    var currentLocation = CLocationManager.shared.location
    
    
    var games = [Game]()
    var userGames = [Game]()
    var gamesToDisplay = [Game]()
    var upcomingGames = [UpcomingGame]()
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 0 {
            if gamesToDisplay.count == 0  {
                return 1
                
            } else {
                return gamesToDisplay.count
            }
        } else { //this means is that it a table view about upcoming games
            if upcomingGames.count == 0 {
                return 1
            } else {
                return upcomingGames.count
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0 {
            if gamesToDisplay.count != 0 {

                UserDefaults.standard.set(indexPath.row , forKey: "userSelectedIndex")
                self.performSegue(withIdentifier: "gameTapped", sender: self)
            } else  {
                print("Tapped")
                self.performSegue(withIdentifier: "gamesToCreateGame", sender: nil)
                //nothing happens when there is no games, maybe it can go to create a game...
            }
        } else {
            //upcoming Games
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? GameViewController {
            
            let gameIndex = UserDefaults.standard.integer(forKey: "userSelectedIndex")
            destination.currentGame = gamesToDisplay[gameIndex]
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        //this is for the games collection view
        if collectionView.tag == 0 {
            
        
            
            //If there are no games
            if games.count != 0 {
                
                //shadows of the cards
                print("Games = \(games.count)")
                guard let cell = gameCollection.dequeueReusableCell(withReuseIdentifier: "gamesCVC", for: indexPath) as? gamesCVC else {
                    fatalError("There was a big problem")
                }
                cell.layer.cornerRadius = 2
                cell.layer.borderWidth = 0.0
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.layer.shadowRadius = 1
                cell.layer.shadowOpacity = 1
                cell.layer.masksToBounds = false
                
                let distanceInMeters = gamesToDisplay[indexPath.row].locationCoordinates.distance(from: currentLocation!)
                let distanceMiles = ((distanceInMeters*0.00062137)*10).rounded() / 10
                
                
                //setting up the properties
                cell.distance.text = "Distance \(distanceMiles) miles away"
                cell.locationOfGame.text = gamesToDisplay[indexPath.row].placeAddress.nameOfPlace
                cell.sportOfGame.text = gamesToDisplay[indexPath.row].sport
                cell.dateOfGame.text = gamesToDisplay[indexPath.row].dateString
                cell.timeOfGame.text = gamesToDisplay[indexPath.row].timeString
                cell.nameOfGame.text = gamesToDisplay[indexPath.row].nameOfGame
                cell.numberOfPlayers.text = "\(gamesToDisplay[indexPath.row].userList.count) players"
                
                return cell
            } else {
                //if there is no game then it will use the regular collection view cell
               
                
                print("It is going through here")
                
                let cell = gameCollection.dequeueReusableCell(withReuseIdentifier: "noGamesCollectionViewCell", for: indexPath) as! noGamesCollectionViewCell
                cell.layer.cornerRadius = 2
                        cell.layer.borderWidth = 0.0
                        cell.layer.shadowColor = UIColor.black.cgColor
                        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                        cell.layer.shadowRadius = 1
                        cell.layer.shadowOpacity = 1
                        cell.layer.masksToBounds = false
                return cell
            }
        } else {
            //this is for the upcoming games tab
            
            if upcomingGames.count != 0 {
                
                let cell = upCGCollection.dequeueReusableCell(withReuseIdentifier: "upComingGamesCollectionViewCell", for: indexPath) as! upComingGamesCollectionViewCell
                cell.layer.cornerRadius = 2
                        cell.layer.borderWidth = 0.0
                        cell.layer.shadowColor = UIColor.black.cgColor
                        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                        cell.layer.shadowRadius = 1
                        cell.layer.shadowOpacity = 1
                        cell.layer.masksToBounds = false
                return cell
            } else {
                //no games in the array
               
                
                print("It is going through here")
                let cell = upCGCollection.dequeueReusableCell(withReuseIdentifier: "noUCG", for: indexPath) as! noUCG

                cell.layer.cornerRadius = 2
                        cell.layer.borderWidth = 0.0
                        cell.layer.shadowColor = UIColor.black.cgColor
                        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                        cell.layer.shadowRadius = 1
                        cell.layer.shadowOpacity = 1
                        cell.layer.masksToBounds = false
                return cell
            }

            //this is for the upcomingGames collection view
            
            
        }

            

        
    }
    
    func filterUserGames() {
        userGames.removeAll()
        for game in games {
            if game.userMap.contains(where: { (key: String, value: [String : Any]) in
                if key == userID {
                    return true
                } else {
                    return false
                }
            }) {
                userGames.append(game)
            }
                
        }
    }
    
    func loadUpcomingGames() {
        
    }
    


    
    func loadGames() {
        let db = Firestore.firestore()

        db.collection("games").whereField("date", isGreaterThan: Timestamp.init()).whereField("based", isEqualTo: defaults.string(forKey: "userstate") ?? "").addSnapshotListener { [self] (querySnapshot, err) in
            if let err = err {
            print(err)
        }
            else {
                
               
                self.games.removeAll()
                for document in querySnapshot!.documents{
                    
                    let game = Game.init(gameDocument: document.data(), documentID: document.documentID)
                    
                    print("There is \(games.count)")
                    let meters = game.locationCoordinates.distance(from: currentLocation!)
                    let distanceMiles = ((meters * 0.00062137)*10) / 10
                    
                    if game.gamePrivate == false {
                        if distanceMiles < 150 {
                            self.games.append(game)
                        }
                    }
                }
                //organizes games from closest  to farthest
                self.gamesToDisplay = self.games.sorted(by: {$0.locationCoordinates.distance(from: currentLocation!) < $1.locationCoordinates.distance(from: currentLocation!)})
            }
            
            gameCollection.reloadData()
        }
    }
    

    @IBOutlet weak var upCGCollection: UICollectionView!
    
    @IBOutlet weak var gameCollection: UICollectionView!
    
    override func viewDidAppear(_ animated: Bool) {
        CLocationManager.shared.start { (info) in
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameCollection.delegate = self
        gameCollection.dataSource = self
        
        upCGCollection.delegate = self
        upCGCollection.dataSource = self
        
        let nib = UINib(nibName: "gamesCVC", bundle: nil)
        gameCollection.register(nib, forCellWithReuseIdentifier: "gamesCVC")
        
        let nib2 = UINib(nibName: "noGamesCollectionViewCell", bundle: nil)
        gameCollection.register(nib2, forCellWithReuseIdentifier: "noGamesCollectionViewCell")
        
        let nib3 = UINib(nibName: "upComingGamesCollectionViewCell", bundle: nil)
        upCGCollection.register(nib3, forCellWithReuseIdentifier: "upComingGamesCollectionViewCell")
        
        let nib4 = UINib(nibName: "noUCG", bundle: nil)
        upCGCollection.register(nib4, forCellWithReuseIdentifier: "noUCG")
        
        //this is for games near a person collection view - this takes data from firebase
        
       
     
        
        DispatchQueue.main.async {
            if CLocationManager.shared.location == nil {
                self.present(alertMessage.shared.systemLocation(), animated: true)
                
            } else {
                self.loadGames()
            }
                
            
        }
       
        
        // Do any additional setup after loading the view.
    }
    


}


