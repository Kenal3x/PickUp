
import UIKit
import MapKit

//do not
class SuggestionsTableViewController: UITableViewController {
    
    private var searchCompleter: MKLocalSearchCompleter?
    private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    private var currentPlacemark: CLPlacemark?
    
    var completerResults: [MKLocalSearchCompletion]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SuggestedCompletionTableViewCell.self, forCellReuseIdentifier: SuggestedCompletionTableViewCell.reuseID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startProvidingCompletions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopProvidingCompletions()
    }
    
    private func startProvidingCompletions() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.resultTypes = .pointOfInterest
        searchCompleter?.region = searchRegion
    }
    
    private func stopProvidingCompletions() {
        searchCompleter = nil
    }
    
    func updatePlacemark(_ placemark: CLPlacemark?, boundingRegion: MKCoordinateRegion) {
        currentPlacemark = placemark
        searchCompleter?.region = searchRegion
    }
}

extension SuggestionsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header = NSLocalizedString("SEARCH_RESULTS", comment: "Standard result text")
        if let city = currentPlacemark?.locality {
            let templateString = NSLocalizedString("SEARCH_RESULTS_LOCATION", comment: "Search result text with city")
            header = String(format: templateString, city)
        }
        
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedCompletionTableViewCell.reuseID, for: indexPath)

        if let suggestion = completerResults?[indexPath.row] {
            cell.textLabel?.text = suggestion.title
            cell.detailTextLabel?.text = suggestion.subtitle
        }

        return cell
    }
}

extension SuggestionsTableViewController: MKLocalSearchCompleterDelegate {
    
    /// - Tag: QueryResults
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // As the user types, new completion suggestions are continuously returned to this method.
        // Overwrite the existing results, and then refresh the UI with the new results.
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle any errors returned from MKLocalSearchCompleter.
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}

extension SuggestionsTableViewController: UISearchResultsUpdating {

    /// - Tag: UpdateQuery
    func updateSearchResults(for searchController: UISearchController) {
        // Ask `MKLocalSearchCompleter` for new completion suggestions based on the change in the text entered in `UISearchBar`.
        searchCompleter?.queryFragment = searchController.searchBar.text ?? ""
    }
}

private class SuggestedCompletionTableViewCell: UITableViewCell {
    
    static let reuseID = "SuggestedCompletionTableViewCellReuseID"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
