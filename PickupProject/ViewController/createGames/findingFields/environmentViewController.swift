//
//  environmentViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/23/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import JGProgressHUD
import GoogleMobileAds


class environmentViewController: UIViewController, MKMapViewDelegate, EnvironmentChildViewControllerDelegate, GADFullScreenContentDelegate {
    
    private enum AnnotationReuseID: String {
        case pin
    }
    
    @IBOutlet weak var button: UIBarButtonItem!
    let spinner = JGProgressHUD()
    var count = 0
    var currentLocation = CLocationManager.shared.location
    var games = [Game]()
    var filter = ""
    var filterPlaced = false
    let defaults = UserDefaults.standard
    var selectedGame: Game?
    private var interstitial: GADInterstitialAd?
    
    
    
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    @IBOutlet weak var findFields: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1033173712", request: request, completionHandler: { [self] ad , error in
            if error != nil {
                print(error!.localizedDescription)
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            showAd()


        })
        self.mapView.delegate = self
        
        //this sees if there is a gameinviteId that is parsed from an invite link
        let gameInviteID = UserDefaults.standard.string(forKey: "gameID")
        print(gameInviteID ?? "Nil")
        if gameInviteID != nil {
            let db = Firestore.firestore()
            
            //gets documents
                db.collection("games").document(gameInviteID!).getDocument { document, error in
                    if error != nil {
                        print("There was an error")
                        
                    }
                    if let document = document , document.exists {
                        let game = Game.init(gameDocument: document.data()!, documentID: document.documentID)
                        
                        self.selectedGame = game
                        self.performSegue(withIdentifier: "locationToGameView", sender: self)
                    
                    }
                    
                }
        }
        
  
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        Utilities.styleFilledButton(self.findFields)
        if CLocationManager.shared.location != nil {
            render(location: CLocationManager.shared.location!)
        } else {
            let alert = UIAlertController(title: "Alert", message: "PickUp app requires the use of a user's location in order to efficiently find and create PickUp games for said user", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
                print("dismiss")
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {action in
                print("Settings is picked")
            }))
            
            present(alert,  animated: true)
        }
        
                
        
    }
    
    //when the user does not have a location on
    @IBAction func triggerde(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "PickUp app requires the use of a user's location in order to efficiently find and create PickUp games for said user", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            print("dismiss")
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {action in
            print("Settings is picked")
        }))
        
        present(alert,  animated: true)
        

    }
    func transitionToOnLocationRequest() {
        let locationRequest = storyboard?.instantiateViewController(identifier: Constants.Storyboard.getUserLocationViewController) as? getUserLocationViewController
        view.window?.rootViewController = locationRequest
        view.window?.makeKeyAndVisible()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
      }

    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
    }

    
    @IBAction func touchedFind(_ sender: Any) {
        showMiracle()
     
    }
    
    func setUpModal() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "environmentChild") as! EnvironmentChildViewController
        vc.modalPresentationStyle = .pageSheet
        self.present(vc, animated: true, completion: nil)
    }
    @objc func showMiracle() {
        let slideVC = storyboard?.instantiateViewController(withIdentifier: "environmentChild") as! EnvironmentChildViewController
        slideVC.delegate = self
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    func showAd() {
        if interstitial != nil {
            interstitial!.present(fromRootViewController: self)
            print("An ad has been set")
          } else {
            print("Ad wasn't ready")
          }
        
    }
    
    func filterAnnotations(sport: String) {
        getNearbyFields(filter: sport)
    }


    
   
    

    
    @IBAction func locationCenterTapped(_ sender: Any) {
            
        if CLocationManager.shared.location == nil {
            present(alertMessage.shared.systemLocation() , animated :true)
            
        } else {
            render(location: CLocationManager.shared.location!)
        }
    }
    
}

extension environmentViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//Query Section
extension environmentViewController: CLLocationManagerDelegate{
    
    func findSoccer(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery  = query
        
        request.region = mapView.region
        
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { [self](response,error) in
            guard let response = response else {
                return
            }
            
            
            let annotations = response.mapItems.compactMap { (mapItem) -> PlaceAnnotation? in
                guard let coordinate = mapItem.placemark.location?.coordinate else { return nil }
                
                let annotation = PlaceAnnotation(address: Address(formattedAddress: mapItem.placemark),
                                                 title: mapItem.name ?? "",
                                                 averageRating: 0.0,
                                                 numberOfReviews: 0,
                                                 coordinate: coordinate,
                                                 sport: "soccer", image: UIImage(named: "soccerAnnotation")!,
                                                 game: false,
                                                 subtitle: "",
                                                 id: "")
              
                
                
                return annotation
            }
                self.mapView.addAnnotations(annotations)
        }
        
    }
    
    func findFootball(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery  = query
        request.region = mapView.region
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { [self](response,error) in
            guard let response = response else {
                return
            }
            
            
            
            
            
            let annotations = response.mapItems.compactMap { (mapItem) -> PlaceAnnotation? in
                guard let coordinate = mapItem.placemark.location?.coordinate else { return nil }
                
                let annotation = PlaceAnnotation(address: Address(formattedAddress: mapItem.placemark),
                                             title: mapItem.name ?? "",
                                                 averageRating: 0.0,
                                                 numberOfReviews: 0,
                                                 coordinate: coordinate,
                                                 sport: "football",
                                                 image: UIImage(named:"footballAnnotation")!,
                                                 game: false,
                                                 subtitle: "",
                                                 id: "")
      
                
                return annotation
            }
            self.mapView.addAnnotations(annotations)
        }
        
    }
    
    func findBasketball(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery  = query
        request.region = mapView.region
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { [self](response,error) in
            guard let response = response else {
                return
            }
            
            let annotations = response.mapItems.compactMap { (mapItem) -> PlaceAnnotation? in
                guard let coordinate = mapItem.placemark.location?.coordinate else { return nil }
                let annotation = PlaceAnnotation(coordinate: coordinate)
                annotation.sport = "basketball"
                annotation.title = mapItem.name
                annotation.url = mapItem.url
                annotation.game = false
                annotation.address = Address(formattedAddress: mapItem.placemark)
                annotation.image = UIImage(named: "basketballAnnotation")
                
                
                return annotation
            }
            
            
            self.mapView.addAnnotations(annotations)
        }
        
    }
    
    func getNearbyGames(sport: String) {
        let db = Firestore.firestore()
        
       
        //gonn have to change this to include nearby games in the ongoing games or games that are within a 30 minutes range
        
        //gotta server stamp the is great4er than
        db.collection("games").whereField("date", isGreaterThan: Timestamp.init())
            .whereField("gamePrivate", isEqualTo: false)
            .whereField("sport", isEqualTo: sport)
            .whereField("based", isEqualTo: defaults.string(forKey: "userstate") ?? "")
            .getDocuments { [self] (querySnapshot, err) in
            if let err = err{
                print(err)
            }
            else {
                self.games.removeAll()
                for document in querySnapshot!.documents{
                    
                    let game = Game.init(gameDocument: document.data(), documentID: document.documentID)
                     
                    let meters = game.locationCoordinates.distance(from: CLocationManager.shared.location!)
                    let distanceMiles = ((meters*0.00062137)*10).rounded() / 10

                    //nothing more than 150 miles can be seen on the feed
                    if  distanceMiles < 150{
                        self.games.append(game)
                        
                    }
                }
                
                self.games = self.games.sorted(by: {$0.locationCoordinates.distance(from: CLocationManager.shared.location!) < $1.locationCoordinates.distance(from: CLocationManager.shared.location!)})
            }
                if sport == "Soccer" {
                    for game in games {
                        let coordinates = game.locationCoordinatesAnnotations
                        let annotation = PlaceAnnotation(coordinate: coordinates! )
                        annotation.title = game.nameOfGame
                        annotation.image = UIImage(named: "soccerGameAnnotation")
                        annotation.address = game.address
                        annotation.sport = "soccer"
                        annotation.game = true
                        annotation.subtitle = game.title
                        annotation.id = game.ID
                        
                        
                        
                        
                        mapView.addAnnotation(annotation)
                    }

                } else if sport == "Basketball" {
                    
                
                    for game in games {
                        let coordinates = game.locationCoordinatesAnnotations
                        let annotation = PlaceAnnotation(coordinate: coordinates! )
                        annotation.title = game.nameOfGame
                        annotation.image = UIImage(named: "basketballGameAnnotation")
                        annotation.address = game.address
                        annotation.sport = "basketball"
                        annotation.game = true
                        annotation.subtitle = game.title
                        annotation.id = game.ID
                        
                        
                        
                        mapView.addAnnotation(annotation)
                    }

                } else {
                    for game in games {
                        let coordinates = game.locationCoordinatesAnnotations
                        let annotation = PlaceAnnotation(coordinate: coordinates! )
                        annotation.title = game.nameOfGame
                        annotation.image = UIImage(named: "footballGameAnnotation")
                        annotation.address = game.address
                        annotation.sport = "football"
                        annotation.game = true
                        annotation.subtitle = game.title
                        annotation.id = game.ID
                        
                        
                        mapView.addAnnotation(annotation)
                    }

                }
            
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String , gameID: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let joinGame = UIAlertAction(title: "Join Game", style: .default, handler: {(value) in
            let db = Firestore.firestore()
            db.collection("games").document(gameID).setData(["users" : [user?.uid: [ "name" : user?.displayName , "ppURL" : user?.photoURL?.absoluteString ?? ""]
            ]], merge: true)
            db.collection("users").document(user?.uid ?? "user is not detected").setData( ["validGames" :[ gameID : FieldValue.serverTimestamp()]] , merge: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel, handler: nil)
        alertController.addAction(joinGame)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func topmostController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    func getNearbyFields(filter: String) {
        //clears past annotations before making new annotations
        
        if CLocationManager.shared.location == nil {
            DispatchQueue.main.async {
                self.present(alertMessage.shared.systemLocation() , animated: true)
                print("alert should be coming out")
                CLocationManager.shared.start { (info) in
                    
                }
            }
            
        } else {
            if let annotations = self.mapView?.annotations {
                for _annotation in annotations {
                    if let annotation = _annotation as? MKAnnotation
                    {
                        self.mapView.removeAnnotation(annotation)
                    }
                }
            }
            if filter == "soccer" {
                findSoccer(query: "Sports Field")
                findSoccer(query: "Soccer field")
                getNearbyGames(sport: "Soccer")
            } else {
                
                findBasketball(query: "basketball court")
                findBasketball(query: "community basketball hoop")
                getNearbyGames(sport: "Basketball")
            }
            
            render(location: CLocationManager.shared.location!)
        }
        


    }
    
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PlaceAnnotation else {return nil}
        //need to change this later on to include cases.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        var annotationView: MKAnnotationView?
        
            // Better to make this class property
            let annotationIdentifier = "AnnotationIdentifier"
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            }
            else {
                //sets up the properties of each annotation
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
                annotationView?.canShowCallout = true
                annotationView?.clusteringIdentifier = "searchResult"
                
                var nameLbl: UILabel! = UILabel(frame: CGRect(x: -24, y: 40, width: 100, height: 30))
                var subLbl: UILabel! = UILabel(frame: CGRect(x: -40, y: 40, width: 100, height: 30))
                nameLbl.tag = 42    //set tag on it so we can easily find it later
                nameLbl.textColor = UIColor.white
                nameLbl.font = UIFont(name: "Roboto", size: 8)
                nameLbl.numberOfLines = 4
                nameLbl.textAlignment = NSTextAlignment.center
                subLbl.textColor = UIColor.white
                subLbl.font = UIFont(name: "Roboto", size: 8)
                subLbl.numberOfLines = 4
                subLbl.textAlignment = NSTextAlignment.center
                annotationView?.addSubview(nameLbl)
                annotationView?.addSubview(subLbl)
                
            }

            if let annotationView = annotationView {
                // Configure your annotation view here
                annotationView.canShowCallout = true
                let pinImage = annotation.image
                let size = CGSize(width: 50, height: 50)
                UIGraphicsBeginImageContext(size)
                pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                annotationView.image = resizedImage
            }
            
            //sets the label
            let cpa = annotation as! PlaceAnnotation
            if let nameLbl = annotationView?.viewWithTag(42) as? UILabel{
                nameLbl.text = cpa.title
                
            
                
            }
        
        return annotationView

        // Better to make this class property
        
    }
    
    //22222
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let view = view.annotation as? PlaceAnnotation
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let extraDetailVC = storyBoard.instantiateViewController(withIdentifier: "extraDetailsViewController") as! extraDetailsViewController
        //the random let variable here just randomly starts the view
        let _ = extraDetailVC.view
    
        
        if view?.game == false {
            
            //if annotation on the map is not a game, then we can just proceed to create a game
            let extraDetailVC = storyBoard.instantiateViewController(withIdentifier: "extraDetailsViewController") as! extraDetailsViewController
            //the random let variable here just randomly starts the view
            let _ = extraDetailVC.view
            print("game is \(view?.game)")
            
            extraDetailVC.locationName?.text = view?.title ?? ""
            extraDetailVC.placeLocation = view?.address
            extraDetailVC.locationCoordinates = view?.coordinate
            
            
            
            navigationController?.pushViewController(extraDetailVC, animated: true)
        } else {
            
        
            //
        }

        
        /*let launchOptions = [MKLaunchOptionsMapCenterKey: view?.coordinate]
        view?.mapItem().openInMaps(launchOptions: launchOptions as [String : Any])*/
    }
    
    
    
    
    func render( location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate , span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            self.transitionToOnLocationRequest()
        } else if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       if let error = error as? CLError, error.code == .denied {
          // Location updates are not authorized.
          manager.stopMonitoringSignificantLocationChanges()
          return
       }
       // Notify the user of any errors.
    }
    
    
    
 

    
    
}

extension environmentViewController {
   
}


extension environmentViewController {
    func reverseGeocoder(completionHander: @escaping (CLPlacemark?) -> Void?) {
        if let lastLocation = self.locationManager.location {
               let geocoder = CLGeocoder()
                   
               // Look up the location and pass it to the completion handler
               geocoder.reverseGeocodeLocation(lastLocation,
                           completionHandler: { (placemarks, error) in
                   if error == nil {
                       let firstLocation = placemarks?[0]
                       completionHander(firstLocation)
                   }
                   else {
                    // An error occurred during geocoding.
                    completionHander(nil)
                   }
               })
           }
           else {
               // No location was available.
               completionHander(nil)
           }
       }
    
    
}

extension environmentViewController {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            manager.requestLocation()
            print("not determeined")
        case .restricted, .denied:
            present(alertMessage.shared.systemLocation() , animated: true)
        case  .authorizedWhenInUse , .authorizedAlways:
            print("It is in use")
            break

        @unknown default:
            break
        }
    }
}



public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
