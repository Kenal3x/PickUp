//
//  ChatViewController.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/9/21.
//

import UIKit
import MessageKit
import FirebaseAuth
import InputBarAccessoryView
import JGProgressHUD

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
    
}

extension MessageKind {
    
    var messageKindString: String {
        switch self {
        
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}


struct Sender: SenderType{
    public var photoURL: String
    public var senderId: String
    public var displayName: String
    
    
}

class ChatViewController: MessagesViewController {
    
    
    @IBOutlet weak var reportBUTTON: UIBarButtonItem!
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    
    let spinner = JGProgressHUD()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)
        let reportItem = UIBarButtonItem(title: "Report", style: .done, target: nil, action: #selector(flagConversation))
        navigationItem.rightBarButtonItem = reportItem
        
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
        
        
    }
    
    public static  var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    public let otherUserUID: String
    public var conversationId: String?
    public var isNewConversation = false
    
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return Sender(photoURL: "", senderId: user.uid, displayName: user.displayName ?? "")
        
    }
    //id is conversation ID
    init(with userID: String , id: String?){
        self.conversationId = id
        self.otherUserUID = userID
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
            print("ChatView is being iniatilized with this \(conversationId)")
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        

        

        // Do any additional setup after loading the view.
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == self.selfSender?.senderId {
            //show your own pp
            if let currentUserImageURL = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            } else {
                StorageManager.shared.downloadURL(for: "\(user!.uid)/profilePicture.jpeg", completion: { [weak self]result in
                    switch result    {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    
                    case .failure(let error):
                        print("This is an error while cnfiguring the avartar view \(error)")
                    }
                })
                //fetch url
            }
        } else {
            if let otherUserPhotourl = self.otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserPhotourl, completed: nil)
            } else {
                StorageManager.shared.downloadURL(for: "\(otherUserUID)/profilePicture.jpeg", completion: { [weak self]result in
                    switch result    {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    
                    case .failure(let error):
                        print("This is an error while cnfiguring the avartar view \(error)")
                        DispatchQueue.main.async {
                            avatarView.image = UIImage(named: "blankProfile")
                        }
                    }
                })
            }
        }
    }
     
    
    @IBAction func flagConversation() {
        
    let alert = UIAlertController(title: "Flagging Conversation", message: "Why will you be reporting this conversation?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "User makes me feel unsafe", style: .default, handler: {action in
            DatabaseManager.shared.flagConversation(with: self.conversationId ?? "", reportedUserID: self.otherUserUID, reason: "unsafe" , completion: {result in
                switch result {
                case .success(let reportID):
                    
                    let message = alertMessage.shared.successAlert(with: "Report has been recorded", messageString: "Your reportID is \(reportID)")
                    
                    self.present(message, animated: true)
                case .failure(_):
                    print("There has been an error")
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Racist or insensitive messaging", style: .default, handler: { action in
            DatabaseManager.shared.flagConversation(with: self.conversationId ?? "", reportedUserID: self.otherUserUID, reason: "insensitive" , completion: {result in
                switch result {
                case .success(let reportID):
                    
                    let message = alertMessage.shared.successAlert(with: "Report has been recorded", messageString: "Your reportID is \(reportID), your report will remain anonymous")
                    
                    self.present(message, animated: true)
                case .failure(_):
                    print("There has been an error")
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
            //cancels action
        }))
        
        present(alert, animated: true)
        
    }
    private func listenForMessages(id: String , shouldScrollToBottom: Bool){
        spinner.show(in: view)
                DatabaseManager.shared.getAllMessageConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("we are now listening for \(id)")
                guard !messages.isEmpty else{
                    print("messages are empty \(messages)")
                    return
                }
                
                self?.messages = messages
                DispatchQueue.main.async {
                    
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.spinner.dismiss()
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("Failed to get message : \(error)")
            }
        })
    }
    


}




extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate , MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

//when user presses the send button on the messageView Controlller
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
            let messageID = createMessageId() else {
            return
        }
        //send message
        
        
        let message = Message(sender: selfSender
                              , messageId: messageID
                              , sentDate: Date(), kind: .text(text))
    
        spinner.show(in: view)
        if isNewConversation {
            
            
            DatabaseManager.shared.createNewConversation(with: otherUserUID, firstMessage: message, name: self.title ?? "User", completion: {[weak self] success in
                if success{
                    print("I am creating a new conversation")
                    print(self!.isNewConversation)
                        self?.isNewConversation = false
                        let newConversationID = "conversations\(message.messageId)"
                    self?.conversationId = newConversationID
                    self?.listenForMessages(id: newConversationID, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                    self!.spinner.dismiss()
                } else {
                    print("failed to send")
                }
            })
            //create convo in database
        }
        else {
            
            guard let conversationId = conversationId ,let name = self.title else {

                return
                
            }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserUID: otherUserUID, name: name , newMessage: message, completion: {success in
                if success {
                    self.messageInputBar.inputTextView.text = nil
                    self.spinner.dismiss()
                    
                
                } else {
                    print("Message is not being sent")
                }
            })
            //append to existing conversation data
        }
    }
    
    
    private func createMessageId() -> String?{
        
        guard let currentUserEmail = user?.email else{
            return nil
        }
        
        let dateString = Self.dateFormatter.string(from: Date())
        let messageID = "\(otherUserUID)\(dateString)"
        //date, otherUserEmail,, senderEmail, randomInt
        return messageID
        
    }
    
}
