//
//  alertMessages.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/30/21.
//

import Foundation
import FirebaseFirestore
import UIKit


final class alertMessage {
    static let shared = alertMessage()
}


extension alertMessage {
    public func successAlert(with title: String , messageString: String ) -> UIAlertController{
        let alert = UIAlertController(title: title, message: messageString, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            print("succesful dismissed")
        }))
        return alert
        
    }
    
    
    public func systemLocation() -> UIAlertController{
        let alert = UIAlertController(title: "Alert", message: "Please share your location, in order to find and create PickUp Games", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            print("Dismiss")
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }))
        
        return alert
    }
}
