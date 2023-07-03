//
//  userListViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/30/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth



class userListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var currentGame: Game?
    @IBOutlet weak var tableView: UITableView!
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nib = UINib(nibName: "playerListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "playerListTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        //this gets data specifically from the user. We get the data from the map and append it into a list

        

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentGame!.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerListTableViewCell", for: indexPath) as!
            playerListTableViewCell
        //If user is the owner of the game??
        if currentGame?.userList[indexPath.row].userID == currentGame?.userList[0].userID {
            //going to check who has the ball
            cell.userRole.text = "Owner"
            cell.userDisplayName.text = String(describing: currentGame!.userList[indexPath.row].name)
        } else {
            //user is not the owner
            cell.userRole.text = "Member"
            cell.userDisplayName.text = String(currentGame!.userList[indexPath.row].name)
             
        }
        
        
        //have to change it where a profile picture retrivies the profile picture's url through firebase
        if currentGame!.userList[indexPath.row].userpp == ""{
            cell.userProfilePicture.image = UIImage(named: "blankprofile")
        } else {
            let imageUrl = URL(string: currentGame!.userList[indexPath.row].userpp)

            let imageData = try! Data(contentsOf: imageUrl!)

            let image = UIImage(data: imageData)
            cell.userProfilePicture.image = image
        }
        


        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "gameToPlayerProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GamesToProfileViewController {
            destinationVC.userID = (currentGame!.userList[tableView.indexPathForSelectedRow!.row]).userID
            
            
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
