//
//  GamesToProfileViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/1/21.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import JGProgressHUD


class GamesToProfileViewController: UIViewController {
    
    public var completion: ((SearchResult) -> (Void))?
    
    
    
    let spinner = JGProgressHUD()
    @IBOutlet weak var profilePicture: UIImageView!

    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var mainBody: UIView!
    @IBOutlet weak var accountCreation: UILabel!
    @IBOutlet weak var gamesPlayed: UILabel!
    @IBOutlet weak var playerstate: UILabel!
    var username: String!
    let userData = [User]()
    
    var userID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    
    func setupUI() {
//        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
//    
//        profilePicture.layer.borderColor = UIColor.black.cgColor
//        profilePicture.layer.borderWidth = 8
//        profilePicture.clipsToBounds = true
        
        mainBody.layer.cornerRadius = 40.0
        mainBody.clipsToBounds = false
        
        messageButton.layer.borderWidth = 5
        messageButton.layer.borderColor = UIColor.black.cgColor
        messageButton.layer.backgroundColor = UIColor.white.cgColor
        messageButton.layer.cornerRadius = 20
    }
    
    func setUpElements() {
        
        spinner.show(in: view)
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { [self] document, error in
            if error != nil {
                print("There is an error")
            }
            
            if let document = document, document.exists {
                
                let userData = User.init(userDocument: document.data()!, documentID: document.documentID )
                
                
                DispatchQueue.main.async {
                    if userData.imageURL == "" {
                        profilePicture.image = UIImage(named: "blankprofile")?.circleMask
                    } else {
                        let imageUrl = URL(string: userData.imageURL)!

                        let imageData = try! Data(contentsOf: imageUrl)

                        let image = UIImage(data: imageData)
                        profilePicture.image = image?.circleMask
                        
                    }
                    
                    gamesPlayed.text = String(userData.userGames.count)
                    accountCreation.text = userData.creationDateString
                    playerstate.text =  userData.state
                    username = userData.displayName
                    userDisplayName.text = userData.displayName
                    spinner.dismiss()
                }
                
                
                
                
                
            } else {
                print("there has been an error")
            }
            
            
        }
    }
    
    private func createNewConversation(result: SearchResult) {
        
        
        let name = result.name
              //the other user's uid
        let uid = result.uid
        DatabaseManager.shared.conversationExists(with: uid, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let conversationId):
                print("conversation already exists \(conversationId)")
                let vc = ChatViewController(with: uid, id: conversationId)
                vc.isNewConversation = false
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = name
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                
            case . failure(_):
                print("conversation doesnt exist")
                let vc = ChatViewController(with: uid, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        // we pass nil cuz no id yet for the chat this for the old code
//        let vc = ChatViewController(with: email , id: nil)
//        vc.isNewConversation = true
//        vc.title = name
//        vc.navigationItem.largeTitleDisplayMode = .never
//        navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func buttonPressed(_ sender: Any) {
        
        let result = SearchResult(name: username, uid: userID, email: "")
        createNewConversation(result: result)
//        let result = SearchResult(name: username, uid: userID)
//        self.completion?(result)
        
        
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
