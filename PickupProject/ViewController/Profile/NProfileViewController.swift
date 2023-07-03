//
//  NProfileViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 8/16/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import JGProgressHUD

class NProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var currentUser = Auth.auth().currentUser
    private let spinner = JGProgressHUD()
    
    @IBOutlet weak var created: UILabel!
    var user: User?

    var didUserFinishOnboarding : Bool?
    
    private let storage = Storage.storage().reference()
    
    @IBOutlet weak var nameOfUser: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var mainBody: UIView!
    @IBOutlet weak var upcomingGameButton: UIButton!
    @IBOutlet weak var numberOfGames: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpElements()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("this is the user's profile picture url \(user?.imageURL)")
       
        self.spinner.show(in: self.view)
        
        if user == nil {
            noAccount()
        }
        
        setUpProfile()

        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String ,
            let url = URL(string: urlString) else {
                return
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data , _, error in
            guard let data =  data, error == nil else {
                return
            }
            
            //make sure this iniaitilizes when data is rady
            DispatchQueue.main.async {
                
                let image = UIImage(data: data)
                self.profilePicture.image = image
                
            }
            
        })
        
        task.response
        
        
        
        // Do any additional setup after loading the view.
    }
    func noAccount(){
        let goToAccount = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginNavViewController) as! loginNavViewController
        
        view.window?.rootViewController = goToAccount
        view.window?.makeKeyAndVisible()
    }
    
    
    @IBAction func changeProfilePictureTapped(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker,animated: true)
        
    }
    
    func transitionToOnboarding () {
        let onboardingViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.atheleteProfileUINavigationViewController) as? atheleteProfileUINavigationViewController
        view.window?.rootViewController = onboardingViewController
        view.window?.makeKeyAndVisible()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goUpcomingGame" {
            
        
        }
        
        if segue.identifier == "settings" {
            if let destinationVC = segue.destination as? settingsViewController {
                destinationVC.userData = user
            }
        }
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        
        let ref = storage.child("\(currentUser!.uid)/profilePicture.jpeg")
        
        ref.putData(imageData, metadata: nil, completion: { [self]_ , error in
            guard error == nil else {
                print("failed to upload")
                
                return
            }
            
            self.storage.child("\(currentUser!.uid)/profilePicture.jpeg").downloadURL(completion: {
                url ,error in
                guard let url = url , error == nil else {
                    return
                }
                
                let db = Firestore.firestore()
                let user = Auth.auth().currentUser
                let urlString = url.absoluteString
                print("download string \(urlString)")
                db.collection("users").document(user!.uid).setData(["imageURL": urlString], merge: true)
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.photoURL = url
                changeRequest?.commitChanges { error in
                    
                    
                    print("this is the error \(error?.localizedDescription)")
                }
                
                
                print("Here is the user profile URL\(user?.photoURL?.absoluteString)")
                UserDefaults.standard.set(urlString ,  forKey: "url")
                
            })
        })
            
        
        
        
        //upload image data
        // get download URL
        //save download URL to user defaults
    }
    


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upcomingGameData(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goUpcomingGame", sender: self)
    }
    
    @IBAction func unwindVC(segue: UIStoryboardSegue) {
        
    }
    
    func setUpProfile() {
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser!.uid).addSnapshotListener { [self] document, error in
            if error != nil {
                self.noAccount()
            }
            
            if let document = document, document.exists {
                
                let userData = User.init(userDocument: document.data()!, documentID: document.documentID )
                
                
        
                
                DispatchQueue.main.async {
                    
                    user = userData
                    if userData.imageURL == "" {

                        profilePicture.image = UIImage(named: "blankprofile")?.circleMask
                        print("it is a blank profile")
                    } else {
                        let imageUrl = URL(string: userData.imageURL)!

                        let imageData = try! Data(contentsOf: imageUrl)
                        print("it is not a blank profile")

                        let image = UIImage(data: imageData)
                        profilePicture.image = image?.circleMask
                    }
                    
                    
                    let arrayOfGames = userData.userGames
                    print("There is an amount of games\(String(describing: arrayOfGames.count))")
                    
                    numberOfGames.text = String(arrayOfGames.count)
                    nameOfUser.text = userData.displayName
                    stateLabel.text = " \(userData.state)"
                    
                    
                    created?.text = userData.creationDateString
                    
                
                    
                    self.spinner.dismiss()
                    
                }
                
                
                
                
                
            } else {
                print("there has been an error")
            }
            
            
        }
        
        
        
        
        
        
        
        
    }
    
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    */
    
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "SignOut", message: "You are signing out", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "SignOut", style: .destructive, handler: {action in
            do {
                try Auth.auth().signOut()
            } catch let error {
                // handle error here
                print("Error trying to sign out of Firebase: \(error.localizedDescription)")
            }
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            print("it has been dismissed")
        }))
        
        present(alert, animated: true)
        
        
    }
    
}





extension NProfileViewController {
    func setUpElements() {
//        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
//        profilePicture.layer.borderColor = UIColor.black.cgColor
//        profilePicture.layer.borderWidth = 8
//        profilePicture.clipsToBounds = true
    
        
        
       

//        profilePicture.image = UIImage(named: "blankprofile")?.circleMask

        
        
        
        mainBody.layer.cornerRadius = 40.0
        mainBody.clipsToBounds = false
        
        
    }

}

extension UIImage {
    var circleMask: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
                let imageView = UIImageView(frame: .init(origin: .init(x: 0, y: 0), size: square))
                imageView.contentMode = .scaleAspectFit
                imageView.image = self
                imageView.layer.cornerRadius = square.width/2
                imageView.layer.borderColor = UIColor.black.cgColor
                imageView.layer.borderWidth = 30
                imageView.layer.masksToBounds = true
                UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
                defer { UIGraphicsEndImageContext() }
                guard let context = UIGraphicsGetCurrentContext() else { return nil }
                imageView.layer.render(in: context)
                return UIGraphicsGetImageFromCurrentImageContext()
    }
}
