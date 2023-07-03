//
//  ConversationsViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/9/21.
//

import UIKit
import FirebaseAuth

struct Conversation {
    let id: String
    let name: String
    let otherUserUID: String
    let latestMessage: LatestMessage

}



struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}


class ConversationsViewController: UIViewController {
     
    
    @IBOutlet weak var tableView: UITableView!
    private var conversations = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(NoConvoLabel)
        tableView.delegate = self
        tableView.register(conversationTableViewCell.self, forCellReuseIdentifier: conversationTableViewCell.identitier)
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        validateAuth()
        startListeningForConversations()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NoConvoLabel.frame = CGRect(x: 10, y: (view.height-100)/2,
                                    width: view.width-20,
                                    height: 100)

    }
    
    private let NoConvoLabel: UILabel = {
        let label = UILabel()
        label.text = "No current Conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    private func startListeningForConversations() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        DatabaseManager.shared.getAllConversations(for: user.uid, completion: {[weak self]result in
            switch result {
            case.success(let conversations):
            
                
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.NoConvoLabel.isHidden = false
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case.failure(let error):
                self!.NoConvoLabel.isHidden = false
                self?.tableView.isHidden = true
                print("Failed to get conversations \(error)")
            }
        })
         
    }
    
    
    @IBAction func createConvo(_ sender: Any) {
        
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
//            print("\(result)")
//            self?.createNewConversation(result: result)
            guard let strongSelf = self else {
                return
            }
            let currentConversations = strongSelf.conversations
            
            if let targetConversation = currentConversations.first(where: {
                print("you are trying to connect with \(result.uid)")
                return $0.otherUserUID == result.uid
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserUID, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                print("It is going through here")
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
        
        
    }
    private func createNewConversation(result: SearchResult) {
        // Have to check if this shit actuallt works
        
        let name = result.name
              //the other user's uid
        let uid = result.uid 
        DatabaseManager.shared.conversationExists(with: uid, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let conversationId):
                print("conversation already exists \(conversationId)")
                let vc = ChatViewController(with: uid, id: conversationId)
                vc.isNewConversation = false
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = name
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                
            case . failure(_):
                print("conversation doesnt exist")
                let vc = ChatViewController(with: uid, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        // we pass nil cuz no id yet for the chat this for the old code
//        let vc = ChatViewController(with: email , id: nil)
//        vc.isNewConversation = true
//        vc.title = name
//        vc.navigationItem.largeTitleDisplayMode = .never
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let goToAccount = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginNavViewController) as! loginNavViewController
                
            view.window?.rootViewController = goToAccount
            view.window?.makeKeyAndVisible()
            
            
        }
    }
    



}

extension ConversationsViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: conversationTableViewCell.identitier, for: indexPath) as! conversationTableViewCell
        let model = conversations[indexPath.row]
        cell.configure(with: model)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherUserUID , id: model.id)
        print("Conversation that is selcted is \(model.id)")
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
}
