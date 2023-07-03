//
//  settingsViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/31/21.
//

import UIKit

class settingsViewController: UIViewController {
    var userData: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func privacyPolciy(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.projectpickup.app/terms-and-conditions")!)
    }
    
    @IBAction func aboutUs(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.projectpickup.app/about-us")!)
    }
    
    @IBAction func contactUs(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.projectpickup.app/contact-us")!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? editProfileViewController {
            destinationVC.userData = userData
        }
    }
    
}
