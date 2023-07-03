//
//  constants.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 4/14/21.
//

import Foundation
import GoogleMobileAds

struct Constants {
    struct Ads {
        //this is for the big ad
        static let homeADID = "ca-app-pub-7595028901666229/7488807006"
    }
    
    struct appInfo {
        static let bundleID = "com.projectpickupapp.pickup"
        static let appstoreID = "1581292979"
        static let appLogoURL = "https://lh6.googleusercontent.com/_MADfZL6aC8kPUk3pe3KO5fqLGAYYs-nvLM_GT2QOm8ZDZPYjluI7f2awo69YlRcYn7OfZ0JrZUz7t-tuAMkHxk=w16383"
    }
    
    struct websiteInfo {
        
    }
    struct Storyboard {
        static let TabViewVC = "HomeVC"
        
        static let loginNavViewController = "loginNavController"
        
        static let atheleteProfileUINavigationViewController = "onboarding"
        
        static let getUserLocationViewController = "locationInfo"
        
        static let createGamesFilterViewController = ""
        
        static let chatViewController = "ChatViewController"
        
        static let phoneNumberAuthController = "numberVerify"
        
        
    }
}
