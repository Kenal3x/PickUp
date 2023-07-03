//
//  NewConversationViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/9/21.
//

import UIKit
import JGProgressHUD
import FirebaseFirestore
import FirebaseCore

struct SearchResult {
    let name: String
    let uid: String
    let email: String

}


class NewConversationViewController: UIViewController {
    public var completion: ((SearchResult) -> (Void))?
    private let spinner = JGProgressHUD()
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
    private var searchBar: UISearchBar {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        searchBar.delegate = self
        
        return searchBar
    }
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Users found"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21 , weight: .medium)
        return label
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    


}


extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("It is runnning")
        
        guard let text = searchBar.text , !text.replacingOccurrences(of: " ", with: "") .isEmpty else{
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(query: text ?? "")
    }
    
 
    
    func searchUsers(query: String) {
        print("this is \(hasFetched)")
        //checks if data is already established, and then searches
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers(completion: {[weak self] result in
                switch result {
                case . success(let usercollection):
                    self?.hasFetched = true
                    self!.users = usercollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users \(error)")
                }
            })
        }
        
        //check map if Firebase has results
        
    }
    
    func filterUsers (with term: String) {
        guard hasFetched else {
            return
        }
        let results: [SearchResult] = users.filter({
            
            guard let uid = $0["uid"] else {
                print("ex")
                return false
            }
            guard let email = $0["email"] else {
                print("exb")
                return false
            }
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            print("This is has the \(name.hasPrefix(term.lowercased()))")
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let uid = $0["uid"] , let name = $0["name"],
                  let email = $0["email"] else {
                return nil
            }
            spinner.dismiss()
            return SearchResult(name: name, uid: uid , email: email)
            
        })
        

        self.results = results
        print("Here is the out come \(results)")

        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
            
        } else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            
            self.tableView.reloadData()
            
        }
    }
    


}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.textLabel?.text = results[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetData = results[indexPath.row]
        dismiss(animated: true , completion: {[weak self] in
            self?.completion!(targetData)
            print("It is sending this data \(targetData)")
        })

    
    

    }
}


