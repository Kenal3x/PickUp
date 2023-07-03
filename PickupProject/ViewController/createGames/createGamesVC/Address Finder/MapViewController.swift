
import UIKit
import MapKit
import FloatingPanel


protocol MapViewControllerDelegate: AnyObject {
    func defineLocation( address: String? , coordinates: CLLocationCoordinate2D?)
}

class MapViewController: UIViewController{
    weak var delegate: MapViewControllerDelegate?
    
    private enum AnnotationReuseID: String {
        case pin
    }
    
    @IBOutlet private var mapView: MKMapView!
    //used to transfer address to createGames view controller
    
    
    @IBOutlet weak var createButton: UIButton!
    var mapItems: [MKMapItem]?
    var boundingRegion: MKCoordinateRegion?
    var finalCoordinates: CLLocationCoordinate2D?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.styleFilledButton(createButton)
        
        if let region = boundingRegion {
            mapView.region = region
        }
        mapView.delegate = self
        
        // Show the compass button in the navigation bar.
        
        mapView.showsCompass = false // Use the compass in the navigation bar instead.
        
        // Make sure `MKPinAnnotationView` and the reuse identifier is recognized in this map view.
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: AnnotationReuseID.pin.rawValue)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard let mapItems = mapItems else { return }

        
        if mapItems.count == 1, let item = mapItems.first {
            title = item.name
                    } else {
            title = NSLocalizedString("TITLE_ALL_PLACES", comment: "All Places view controller title")
        }
        
        // Turn the array of MKMapItem objects into an annotation with a title and URL that can be shown on the map.
        let annotations = mapItems.compactMap { (mapItem) -> PlaceAnnotation? in
            guard let coordinate = mapItem.placemark.location?.coordinate else { return nil }
            let annotation = PlaceAnnotation(coordinate: coordinate)
            annotation.title = mapItem.name
            annotation.url = mapItem.url
            
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Failed to load the map: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PlaceAnnotation else { return nil }
        
        // Annotation views should be dequeued from a reuse queue to be efficent.
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationReuseID.pin.rawValue, for: annotation) as? MKMarkerAnnotationView
        view?.canShowCallout = true
        view?.clusteringIdentifier = "searchResult"
        
        let addButton =  UIButton(type: .contactAdd)
        view?.rightCalloutAccessoryView = addButton
        
        // If the annotation has a URL, add an extra Info button to the annotation so users can open the URL.
        return view
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationController = segue.destination as! CreateGameViewController
        let place = mapItems?.first
        let coordinate = place?.placemark.coordinate
        
        let formattedAddress = place?.placemark.formattedAddress
        
        destinationController.nameOfPlace = place?.placemark.name


        destinationController.locationOfGame?.text = formattedAddress
        destinationController.Address = Address(formattedAddress: place!.placemark)
        destinationController.coordinate = coordinate
        }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        let annotation = view.annotation as? PlaceAnnotation
        title = "Selected \(annotation?.title ?? "")"
        let finalCoordinates: CLLocationCoordinate2D = annotation!.coordinate
        print(finalCoordinates)
    }
}
