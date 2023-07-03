

import UIKit
import CoreLocation
import MapKit


//dont read
class SearchResultTableViewController: UITableViewController {
    
    private enum SegueID: String {
        case showDetail
        case showAll
    }
    
    private enum CellReuseID: String {
        case resultCell
    }
    
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
            viewAllButton.isEnabled = places != nil
        }
    }
    
    private var suggestionController: SuggestionsTableViewController!
    private var searchController: UISearchController!

    @IBOutlet private var viewAllButton: UIBarButtonItem!
    
    private let locationManager = CLLocationManager()
    private var currentPlacemark: CLPlacemark?
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
     
    private var foregroundRestorationObserver: NSObjectProtocol?
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        locationManager.delegate = self
        
        suggestionController = SuggestionsTableViewController(style: .grouped)
        suggestionController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        let name = UIApplication.willEnterForegroundNotification
//        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [unowned self] (_) in
//            // Get a new location when retudrning from Settings to enable location services.
//            self.requestLocation()
//        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Keep the search bar visible at all times.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.delegate = self
        
        /*
         Search is presenting a view controller, and needs the presentation context to be defined by a controller in the
         presented view controller hierarchy.
         */
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocation()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mapViewController = segue.destination as? MapViewController else {
            return
        }
        
        if segue.identifier == SegueID.showDetail.rawValue {
            // Get the single item.
            guard let selectedItemPath = tableView.indexPathForSelectedRow, let mapItem = places?[selectedItemPath.row] else { return }
            
            // Pass the new bounding region to the map destination view controller and center it on the single placemark.
            print(mapItem)
            
            var region = boundingRegion
            region.center = mapItem.placemark.coordinate
            mapViewController.boundingRegion = region
            
            
            
            // Pass the individual place to our map destination view controller.
            mapViewController.mapItems = [mapItem]
        } else if segue.identifier == SegueID.showAll.rawValue {
            
            // Pass the new bounding region to the map destination view controller.
            mapViewController.boundingRegion = boundingRegion
            
            // Pass the list of places found to our map destination view controller.
            mapViewController.mapItems = places
        }
    }

    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = boundingRegion
        
        // Include only point of interest results. This excludes results based on address matches.
        searchRequest.resultTypes = .pointOfInterest
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                self.displaySearchError(error)
                return
            }
            
            self.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            if let updatedRegion = response?.boundingRegion {
                self.boundingRegion = updatedRegion
            }
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Location Handling

extension SearchResultTableViewController {
    private func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            displayLocationServicesDisabledAlert()
            return
        }
        
        let status = CLLocationManager.authorizationStatus()
        guard status != .denied else {
            displayLocationServicesDeniedAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocationServicesDisabledAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "Location services are disabled")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: "OK alert button"), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayLocationServicesDeniedAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DENIED", comment: "Location services are denied")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        let settingsButtonTitle = NSLocalizedString("BUTTON_SETTINGS", comment: "Settings alert button")
        let openSettingsAction = UIAlertAction(title: settingsButtonTitle, style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                // Take the user to the Settings app to change permissions.
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButtonTitle = NSLocalizedString("BUTTON_CANCEL", comment: "Location denied cancel button")
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension SearchResultTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            guard error == nil else { return }
            
            self.currentPlacemark = placemark?.first
            self.boundingRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
            self.suggestionController.updatePlacemark(self.currentPlacemark, boundingRegion: self.boundingRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle any errors returned from Location Services.
    }
}

// MARK: - UITableViewDataSource

extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseID.resultCell.rawValue, for: indexPath)
        
        if let mapItem = places?[indexPath.row] {
            cell.textLabel?.text = mapItem.name
            cell.detailTextLabel?.text = mapItem.placemark.formattedAddress
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header = NSLocalizedString("SEARCH_RESULTS", comment: "Standard result text")
        if let city = currentPlacemark?.locality {
            let templateString = NSLocalizedString("SEARCH_RESULTS_LOCATION", comment: "Search result text with city")
            header = String(format: templateString, city)
        }
        
        return header
    }
}

// MARK: - UITableViewDelegate

extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            search(for: suggestion)
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
        search(for: searchBar.text)
    }
}
