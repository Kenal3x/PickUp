//
//  editProfileViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 8/16/21.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class editProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    

    @IBOutlet weak var sportTextInput: UITextField!
    @IBOutlet weak var sportLevelTextInput: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var commitChangesButton: UIButton!
    
    var userData: User?

    var sportPickerview = UIPickerView()
    private let storage = Storage.storage().reference()
    var sportLevelPickerView = UIPickerView()
    
    let sports = ["Soccer" , "Basketball" , "Football"]
    let sportsLevel = ["Rookie" , "Intermediate" , "Pro-Am" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        

        // Do any additional setup after loading the view.
    }
    
    func setUpUI(){
        
        commitChangesButton.layer.cornerRadius = 20
        commitChangesButton.layer.borderWidth = 1
        commitChangesButton.layer.borderColor = UIColor.black.cgColor
        commitChangesButton.backgroundColor = UIColor.white
        commitChangesButton.clipsToBounds = true
        
        profilePicture.clipsToBounds = true
        profilePicture.layer.cornerRadius = 50
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.borderWidth = 5
        
        sportPickerview.delegate = self
        sportPickerview.dataSource = self
        
        sportLevelPickerView.delegate = self
        sportLevelPickerView.dataSource = self
        
        sportTextInput.inputView = sportPickerview
        sportLevelTextInput.inputView = sportLevelPickerView
        
        sportPickerview.tag = 1
        sportLevelPickerView.tag = 2
        
        
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
    }
    
    
    @IBAction func changeProfileButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    
    
    @IBAction func commitChangesButton(_ sender: Any) {
        var selectedSport = sportTextInput.text
        var selectedSportLevel = sportLevelTextInput.text
        var image = profilePicture.image
        
        guard let imageData = image!.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        
        let ref = storage.child("\(user!.uid)/profilePicture.jpeg")
        
        ref.putData(imageData, metadata: nil, completion: { [self]_ , error in
            guard error == nil else {
                print("failed to upload")
                
                return
            }
            
            self.storage.child("\(user!.uid)/profilePicture.jpeg").downloadURL(completion: {
                url ,error in
                guard let url = url , error == nil else {
                    return
                }
                
                let db = Firestore.firestore()
                let user = Auth.auth().currentUser
                let urlString = url.absoluteString
                print("download string \(urlString)")
                db.collection("users").document(user!.uid).setData(["imageURL": urlString , "sport" : selectedSport ?? userData!.sport , "sportLevel" : selectedSportLevel ?? userData!.sportLevel], merge: true)
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.photoURL = url
                changeRequest?.commitChanges { error in
                    
                    
                    print(error?.localizedDescription)
                }
                
                
                performSegue(withIdentifier: "unwindBackToProfile", sender: self)
                
                UserDefaults.standard.set(urlString ,  forKey: "url")
                
            })
        })
        
        
        
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


extension editProfileViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return sports.count
        case 2:
            return sportsLevel.count
        default:
            return 1
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return sports[row]
        case 2:
            return sportsLevel[row]
            
        default:
            return "Data not found"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            sportTextInput.text = sports[row]
            sportTextInput.resignFirstResponder()
        case 2:
            sportLevelTextInput.text = sportsLevel[row]
            sportLevelTextInput.resignFirstResponder()
        default:
            resignFirstResponder()
            
        }
    
    }
}



extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


extension editProfileViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profilePicture.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
