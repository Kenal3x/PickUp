/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Custom pin annotation for display found places.
*/

import MapKit
import Contacts

//this is not too important lmao
class PlaceAnnotation: NSObject, MKAnnotation {
    
    /*
    This property is declared with `@objc dynamic` to meet the API requirement that the coordinate property on all MKAnnotations
    must be KVO compliant.
     */
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    var url: URL?
    var address: Address?
    var averageRating: Double?
    var numberOfReviews: Int?
    var documentID: String?
    var sport: String?
    var image: UIImage?
    var game: Bool?
    var id: String?

    var category: String?
    
    init(address:Address , title:String , averageRating: Double  , numberOfReviews: Int , coordinate: CLLocationCoordinate2D , sport: String , image: UIImage , game: Bool , subtitle: String , id: String) {
        self.address = address
        self.title = title
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews 
        self.coordinate = coordinate
        self.sport = sport
        self.image = image
        self.game = game
        self.id = id
        
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
        
    }
    
    func mapItem () -> MKMapItem {
        let addressDictionary = [CNPostalAddressStreetKey: address!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title 
        return mapItem
        
    }
    

}

// got this from a different video, this is different a bit from the apple software
class LandMarkAnnotation: NSObject, MKAnnotation {
    var title: String?
    var url: URL?
    var address: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
    
    
    

}

class Address{

    var nameOfPlace: String
    var street: String //street name or thoroughfare
    var city: String //locality
    var postal_code: Int
    var country: String //country
    var state: String
    var fullAddress: String
    var latitude: Double
    var longitude: Double
    
    
    init (nameOfPlace: String ,street: String , city: String ,  postal_code: Int , country: String, state: String, fullAddress: String , latitude: Double , longitude: Double) {
        
        self.nameOfPlace = nameOfPlace
        self.street = street
        self.city = city
        self.postal_code = postal_code
        self.state = state
        self.country = country
        self.fullAddress = fullAddress
        self.latitude = latitude
        self.longitude = longitude
    
        
    }
    init (formattedAddress: MKPlacemark) {
        self.nameOfPlace = formattedAddress.name ?? ""
        self.street = formattedAddress.postalAddress?.street ?? ""
        self.city = formattedAddress.postalAddress?.city ?? ""
        self.postal_code = Int(formattedAddress.postalAddress?.postalCode ?? "00") ?? 0
        self.state = formattedAddress.postalAddress?.state ?? ""
        self.country = formattedAddress.postalAddress?.country ?? ""
        self.latitude = formattedAddress.coordinate.latitude
        self.longitude = formattedAddress.coordinate.longitude
        
        self.fullAddress = "\(String(describing: street)), \(String(describing:city)), \(String(describing:state)) , \(String(describing: postal_code))"
        
        
    }
    
       
    public func getDicionary () -> [String: Any] {
        return ["nameOfPlace" : nameOfPlace ,
                "street" : street,
                "city" : city,
                "postal_code" : postal_code ?? 00000 ,
                "state" : state,
                "country" : country,
                "fullAddress" : fullAddress,
                "latitude" : latitude,
                "longitude" : longitude]
    
    }
    
   
    
    init (addressMap: [String:Any]) {
        self.nameOfPlace = addressMap["nameOfPlace"] as? String ?? ""
        self.street = addressMap["street"] as? String ?? ""
        self.city = addressMap["city"] as? String ?? ""
        self.postal_code = addressMap["postal_code"] as? Int ?? 0
        self.state = addressMap["state"] as? String ?? ""
        self.country = addressMap["country"] as? String ?? ""
        self.latitude = addressMap["latitude"] as? Double ?? 0.0
        self.longitude = addressMap["longitude"] as? Double ?? 0.0
        self.fullAddress = "\(String(describing: street)), \(String(describing:city)), \(String(describing:state)) , \(String(describing: postal_code))"
      
    }
}
