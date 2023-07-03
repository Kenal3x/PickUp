//
//  placeManager.swift
//  PickUp
//
//  Created by Ken Alexopoulos on 2/13/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore
import UIKit
import MapKit



final class placeManager {
    static let shared = placeManager()
}


//this is the place review object
extension placeManager {

    func getNearPlaces () {
        
    }
    
    
    
    
    func createPlaceData  (address: Address , placeGeoHash: GeoPoint , completion: @escaping (Places , Error?) -> Void) {
        let db = Firestore.firestore()
        let placeRef = db.collection("places").document()
        let placesObj = Places.init(uniqueID: placeRef.documentID, nameOfPlace: address.nameOfPlace , urlPictureOfPlace: "" , geoHash: placeGeoHash , reviews: 0.0, placeAddressMap: address.getDicionary())
            
        
        placeRef.setData(placesObj.getDictionary())
        
        completion(placesObj, nil)
        
        
    }
    func getPlaceData (address: Address, placeGeoHash: GeoPoint , completion: @escaping (Places , Error?) -> Void) {
        
        
        
        
        let db = Firestore.firestore()
        let placeRef = db.collection("places")
        
        placeRef.whereField("placeAddress.street", isEqualTo: address.street)
            .whereField("placeAddress.city", isEqualTo: address.postal_code ?? 00000)
            .whereField("placeAddress.country", isEqualTo: address.country)
            .whereField("placeAddress.state", isEqualTo: address.state).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print(err.localizedDescription)
                }
                
                print("These were the documents \(String(describing: querySnapshot?.documents))")
                
                //there is an existing document
            
                
                if querySnapshot?.documents.count != 0 {
                    
                    for document in querySnapshot!.documents  {
                        let place = Places.init(document: document.data(), documentID: document.documentID)
                        
                        completion(place , nil)
                        
                        
                    }
                    
                } else {
                    
                    //there is no existing document
                    
                    
                    //currently creates the document
                    self.createPlaceData(address: address, placeGeoHash: GeoPoint(latitude: address.latitude , longitude: address.longitude )) { (place , error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                        
                        completion(place, nil)
                        
                        
                    }
                }
                //we have to add this to
                
                
            }
    }
    
    
}
