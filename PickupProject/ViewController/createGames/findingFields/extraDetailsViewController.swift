//
//  extraDetailsViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/25/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseCore
import FirebaseFirestore

class extraDetailsViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var pickUpButton: UIButton!
    
    
    var placeLocation: Address? = nil
    var locationCoordinates: CLLocationCoordinate2D!
    var placeData: Places?

    
    @IBOutlet weak var locationAddress: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        placeManager.shared.getPlaceData(address: placeLocation!, placeGeoHash: GeoPoint(latitude: locationCoordinates.latitude, longitude: locationCoordinates.longitude)) { (result , error) in
        
            if error != nil {
                print(error?.localizedDescription)
            }
            //gets the data about the place
            if result != nil {
                
                self.placeData = result
            }
           
            // if there is no data then, just say most of the data is missing
            
        }
        locationAddress.delegate = self
        locationAddress.isScrollEnabled = false
        locationAddress.text = placeLocation?.fullAddress ?? "There has been an error"
        mapLocation()

        
    }
    
    
    
    func mapLocation (){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: locationCoordinates.latitude, longitude: locationCoordinates.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate , span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        
        
    }
    
    
    
    @IBAction func startPickUp(_ sender: Any) {
//        if placeData.uniqueID == nil {
//
//        }
        performSegue(withIdentifier: "segueToCreateGame", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! CreateGameViewController
        destinationController.nameOfPlace = locationName.text
        destinationController.Address = placeLocation //Address type
        destinationController.coordinate = locationCoordinates
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
