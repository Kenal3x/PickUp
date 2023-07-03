//
//  getUserLocationViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/1/21.
//

import UIKit
import Lottie
import CoreLocation


class getUserLocationViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        locationManager.delegate = self
        
        

        // Do any additional setup after loading the view.
    }
    
  
    
    //we need to find an animation for the app to use to get the user's locaiton
    
    
    @IBAction func requestLocation(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    
    
  
    
    func transitionToHome () {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.TabViewVC) as? TabViewVC
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else {
            print("THere has been an error")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: {(value) in
            UIApplication.shared.open(settingURL, options: [:] , completionHandler: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            transitionToHome()
        case .denied , .restricted:
            showAlertToPrivacySettings(title: "Location Services Disabled", message: "Location Services are needed for full functionality of this app")
        case .notDetermined:
            break
        default:
            break
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

