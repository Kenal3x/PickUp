//
//  places.swift
//  PickUp
//
//  Created by Ken Alexopoulos on 2/10/23.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

class Places{
    
    var uniqueID: String
    var nameOfPlace:String
    var urlPictureOfPlace: String
    var geoHash: GeoPoint
    var reviews : Double //this will just be an average of the rating file
    var placeAddressMap: [String: Any]
    var placeAddress : Address
    
    //then we can access future games through its unique id
    
    
    init(uniqueID: String, nameOfPlace: String , urlPictureOfPlace: String , geoHash: GeoPoint , reviews: Double, placeAddressMap: [String: Any] ) {
        
        self.uniqueID = uniqueID
        self.nameOfPlace = nameOfPlace
        self.urlPictureOfPlace = urlPictureOfPlace
        self.geoHash = geoHash
        self.reviews = 0.0
        self.placeAddressMap = placeAddressMap
        self.placeAddress = Address.init(addressMap: placeAddressMap)
    }
    
    init(document : [String: Any] , documentID: String) {
        
        self.uniqueID = document["uniqueID"] as? String ?? ""
        self.nameOfPlace = document["nameOfPlace"] as? String ?? ""
        self.urlPictureOfPlace = document["urlPictureOfPlace"] as? String ?? ""
        self.geoHash = document["geoHash"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.reviews = 0 //temp value
        self.placeAddressMap = document["placeAddress"] as? [String: Any] ?? [:]
        self.placeAddress = Address.init(addressMap: placeAddressMap)
        
        
    }
    
    
   
    func getDictionary () -> [String:Any] {
        
       
        return ["uniqueID" : uniqueID, "nameOfPlace" : nameOfPlace , "urlPictureOfPlace" : urlPictureOfPlace , "geoHash" : geoHash , "reviews" : reviews , "placeAddress" : placeAddress.getDicionary()]
        
    }
    
    
    
    
    
    //its going to be a flat sql
    
}


class reviews: Codable {
    
}
