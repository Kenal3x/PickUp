//
//  locationManager.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/17/21.
//

import Foundation
import CoreLocation
import UIKit

struct Location {
    
    let title: String
    let coordinates: CLLocationCoordinate2D
}



class CLocationManager: NSObject , CLLocationManagerDelegate{
    static let shared = CLocationManager()
    let locationManager: CLLocationManager
    var location: CLLocation?
    var locationInfoCallBack: ((_ info:LocationInformation)->())!
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        
        super.init()
        locationManager.delegate = self
    }
    
    
    func start(locationInfoCallBack:@escaping ((_ info:LocationInformation)->())) {
        self.locationInfoCallBack = locationInfoCallBack
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        
    }
    func updateLocation () {
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            manager.requestLocation()
        case .restricted:
            
            manager.stopUpdatingLocation()
        case .denied:
            
            manager.stopUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let recentLocation = locations.last else {
            return
        }
        
        
        let info = LocationInformation()
        location = recentLocation
        print("This is the recent location\(recentLocation)")
        info.latitude = recentLocation.coordinate.latitude
        info.longitude = recentLocation.coordinate.longitude
        
        
        //now fill address as well for complete information through lat long ..
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(recentLocation) { (placemarks, error) in
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }
            if let city = placemark.locality,
               let state = placemark.administrativeArea,
               let zip = placemark.postalCode,
               let locationName = placemark.name,
               let thoroughfare = placemark.thoroughfare,
               let country = placemark.country {
                info.city     = city
                info.state    = state
                info.zip = zip
                info.address =  locationName + ", " + (thoroughfare as String)
                info.country  = country
                
                UserDefaults.standard.setValue(state, forKey: "userstate")
            }
            
            print("This is the info \(info.address)")
            self.locationInfoCallBack(info)
            
            
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }
    
    
}

class LocationInformation {
    
    
    
    var city:String?
    var address:String?
    var latitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    var zip:String?
    var state :String?
    var country:String?
    
    init(city:String? = "",address:String? = "",latitude:CLLocationDegrees? = Double(0.0),longitude:CLLocationDegrees? = Double(0.0),zip:String? = "",state:String? = "",country:String? = "" ) {
        self.city    = city
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.zip        = zip
        self.state = state
        self.country = country
        
    }
}
