//
//  locationFinderViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/16/21.
//

import UIKit
import MapKit


class locationFinderViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var locations = [Location]()
    
    var searchCompleter = MKLocalSearchComplemeter()
    var searchResults = MKLocalSearchCompletion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.register(UITableViewCell.self , forCellReuseIdentifier: "cell")
        myTableView.dataSource = self
        myTableView.delegate = self
        locationInput.delegate = self
        // Do any additional setup after loading the view.
    }

        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        //will show the different auto completed addresses
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coordinates = locations[indexPath.row].coordinates
        //location will be shown here and will send the full address towards create event form
        
        
    }
    //might uses this later
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationInput.resignFirstResponder()
        if let text = locationInput.text , !text.isEmpty {
            
            LocationManager.shared.findLocations(with: text) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.myTableView.reloadData()
                }
                
            }
        }
        
        return true
    }
    */
}
