//
//  stylesheet.swift
//  PickupProject
//
//  Created by Sharmeen Lalani on 5/15/21.
//

//styling


import Foundation
import UIKit
import CoreLocation

extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }

}

extension Notification.Name {
    /// Notificaiton  when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {

        
        // Create the bottom line

        
        //bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        
       
        
        // Remove border on text fieldw
        textfield.borderStyle = .roundedRect
        textfield.layer.cornerRadius = 10
        textfield.clipsToBounds = true
        textfield.backgroundColor = UIColor.init(red: 255 , green:255 , blue: 255, alpha: 255)
        
        // Add the line to the text field
    }
    
    static func styleTitleLabel(_ label:UILabel) {

        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: bottomLine.frame.height - 2, width: bottomLine.frame.width, height: 2)
        
        
        bottomLine.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 255).cgColor
        

        // Add the line to the text field
        label.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 20
        button.tintColor = UIColor.white
    }
    
    static func styleImportantButton (_ button:UIButton) {
        
        // Filled rounded corner style
        button.layer.borderWidth = 0.5
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.lightGray
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 20
        button.tintColor = UIColor.lightGray
        button.setTitleColor(UIColor.black
                             , for: .normal)
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        // at least one uppercase,
            // at least one digit
            // at least one lowercase
            // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")

        return passwordTest.evaluate(with: password)
    }
    

    
    
    
}

