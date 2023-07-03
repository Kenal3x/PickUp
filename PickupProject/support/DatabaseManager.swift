//
//  DatabaseManager.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/9/21.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth
//used mostly for chat

class userList {
    var uid: String
    var displayName: String
    var email: String
    
    init(uid: String , displayName: String , email: String) {
        self.displayName = displayName
        self.uid = uid
        self.email = email
    }
}
final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
}







extension DatabaseManager {
    
    public func insertUser(with user: userList , completion: @escaping (Bool) -> Void){
        database.child("users/\(user.uid)").setValue(["uid" : user.uid , "username" : user.displayName , "email"  : user.email], withCompletionBlock: { [weak self] error, _ in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                print("failed ot write to database")
                completion(false)
                return
            }

            strongSelf.database.child("userList").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // append to user dictionary
                    print("user collection is \(usersCollection)")
                    let newElement = [
                        "name": user.displayName,
                        "uid": user.uid,
                        "email" : user.email
                        
                    ]
                    usersCollection.append(newElement)
                    print("This is the new collection \(usersCollection)")

                    strongSelf.database.child("userList").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
                else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.displayName,
                            "uid": user.uid,
                            "email" :  user.email
                        ]
                    ]

                    strongSelf.database.child("userList").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
            })
        })
    }

    
    public enum DatabaseError: Error {
           case failedToFetch

           public var localizedDescription: String {
               switch self {
               case .failedToFetch:
                   return "This means blah failed"
               }
           }
       }
    
    public func checkEmail(with email:String , completion: @escaping ((Bool) -> String)){
        database.child(email).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
            return
        })
    }
}
    ///Inserts new user to database
   


///MARK: - Sending / Conversations

extension DatabaseManager {
    
    public func flagGame(with gameID: String, ownerOfGameID: String , reason: String , completion: @escaping (Result<String, Error>) -> Void) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("FlaggedGames").addDocument(data: ["reportGame" : gameID , "ownerID" : ownerOfGameID , "timestamp" : FieldValue.serverTimestamp() , "reason" : reason]) { (error) in
            if error != nil {
                completion(.failure("There has been an error" as! Error))
            }
            print("there has been a success")
            
            //returns documentID to an alert
            completion(.success(ref!.documentID))
            
            
        }
    }
    
    
    public func flagConversation(with conversationID: String, reportedUserID: String , reason: String , completion: @escaping (Result<String , Error>) -> Void) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("flaggedConversations").addDocument(data: ["reportedConversation" : conversationID , "reportedUserID" : reportedUserID ,"userUID" : user!.uid , "timestamp" : FieldValue.serverTimestamp() , "reason" : reason]) { (error) in
            if error != nil {
                completion(.failure("There has been an error" as! Error))
            }
            
            completion(.success(ref!.documentID))
            
            
        }
        
        
        
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String : String]] , Error>)-> Void) {
        database.child("userList").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String : String]] else {
                print("There is an error here")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
            
        })
    }
    
    
    
    public func conversationExists(with otherUserUID: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        database.child("users/\(otherUserUID)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            var senderUID = Auth.auth().currentUser?.uid
            
            
            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetUID = $0["otherUserUID"] as? String else {
                    print("failed to fetch otheruseruid")
                    return false
                }
                return senderUID == targetUID
            }) {
                // get id
                guard let id = conversation["id"] as? String else {
                    print("failed to fetch conversation ID in conversation exists")
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }

                completion(.success(id))
                return
            }
            print("it failed to recieve id")
            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }
    

    ///creates new conversation with target user using email and first message sent.
    public func createNewConversation(with otherUserUID: String , firstMessage: Message , name : String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = database.child("users/\(userID)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user is not found")
                return
            }
            
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversations\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id" : conversationID,
                "otherUserUID" : otherUserUID,
                "name" : name,
                "latestMessage" : [
                    "message": message ,
                    "date": dateString ,
                    "is_read": false
                ],
                
            ]
            
            let recipientNewConversationData: [String: Any] = [
                "id" : conversationID,
                "otherUserUID" : user!.uid,
                "name" : user!.displayName,
                "latestMessage" : [
                    "message": message ,
                    "date": dateString ,
                    "is_read": false
                ],
                
            ]
            //update recipient conversation entry
            self?.database.child("users/\(otherUserUID)/conversations").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                if var conversations = snapshot.value as? [[String : Any]] {
                    conversations.append(recipientNewConversationData)
                    self?.database.child("users/\(otherUserUID)/conversations").setValue(conversations)
                }
                else {
                   //create
                    self?.database.child("users/\(otherUserUID)/conversations").setValue([recipientNewConversationData])
                }
            })
            
            //update current users entry
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //conversation array exists for current user
                //we are going to append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: {[weak self ]error , _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    print(conversationID)
                    self?.finishCreatingConversation(name : name  , conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    
                })
                
            } else {
                print("Convo doesnt exists")
                //convo doesnt exist
                
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: {error , _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    print("finished creating convo with \(conversationID)")
                   
                    self?.finishCreatingConversation(name: name , conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    
                })
            }
        })
        
    }
    
    private func finishCreatingConversation (name: String , conversationID: String , firstMessage: Message, completion: @escaping(Bool)->Void) {
        var message = ""
        switch firstMessage.kind {
        
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let collectionMessage: [String : Any] = [
            "id" : firstMessage.messageId ,
            "type" : firstMessage.kind.messageKindString,
            "content" : message ,
            "date" : dateString ,
            "senderID" : currentUser.uid,
            "is_read": false ,
            "name" :  name
            
        ]
        
        let value: [String : Any] = [
            "messages" : [
                collectionMessage
            ]
        ]
        
        
        database.child("conversations/\(conversationID)").setValue( value , withCompletionBlock: { error ,_ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    /// Fetches and returns all conversations for the user with the email
    public func getAllConversations(for uid: String, completion: @escaping(Result<[Conversation], Error>)-> Void) {
        print(uid)
        database.child("users/\(uid)/conversations").observe(.value , with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                print("there are no conversations")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("It went through here")
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String ,
                      let name = dictionary["name"] as? String ,
                      let otherUserID = dictionary["otherUserUID"] as? String,
                      let latestMessage = dictionary["latestMessage"] as? [String: Any],
                      let date = latestMessage["date"] as? String ,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)

                return Conversation(id: conversationID, name: name, otherUserUID: otherUserID, latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        })
        
    }
    // gets all the messages in a covnersation
    public func getAllMessageConversation(with id: String , completion: @escaping(Result<[Message] , Error>)-> Void) {
        print("We are trying to get messages from this id \(id)")
        database.child("conversations/\(id)/messages").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                print("message is not recieved")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
           
    
            let messages: [Message] = value.compactMap({ dictionary in
//                guard let name = dictionary["name"] as? String ,
//                    let isRead = dictionary["is_read"] as? Bool ,
//                    let messageID  = dictionary["id"] as? String ,
//                    let content = dictionary["content"] as? String,
//                    let senderUID = dictionary["senderID"] as? String,
//                    let type = dictionary["type"] as? String,
//                    let dateString = dictionary["date"] as? String,
//                    let date = ChatViewController.dateFormatter.date(from: dateString) else {
//                    print("it is returning nil")
//                    return nil
//                }
                
                let name = dictionary["name"] as? String ?? ""
                let isRead = dictionary["is_read"] as? Bool ?? false
                let messageID = dictionary["id"] as? String ?? ""
                let content = dictionary["content"] as? String ?? ""
                let senderUID = dictionary["senderID"] as? String
                let type = dictionary["type"] as? String ?? ""
                let dateString = dictionary["date"] as? String
                let date = ChatViewController.dateFormatter.date(from: dateString!)
                
                                
                let sender = Sender(photoURL: "", senderId: senderUID!, displayName: name)
            
                return Message(sender: sender, messageId: messageID, sentDate: date ?? Date(), kind: .text(content))
            })
            print("message is recieved")
            print("These are the messages \(messages)")
            completion(.success(messages))
        })
        
    }
    ///sends a message with a a tarrget conversation and message, return a boolean for an error
    public func sendMessage(to conversation: String, otherUserUID: String ,name: String ,  newMessage: Message, completion: @escaping(Bool)-> Void){
        //add new message to messages
        //update sender last message
        
        self.database.child("conversations/\(conversation)/messages").observeSingleEvent(of: .value, with:{ [weak self ]snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            var message = ""
            switch newMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            guard let currentUser = Auth.auth().currentUser else {
                completion(false)
                return
            }
            
            let newMessageEntry: [String : Any] = [
                "id" : newMessage.messageId ,
                "type" : newMessage.kind.messageKindString,
                "content" : message ,
                "date" : dateString ,
                "senderID" : currentUser.uid,
                "is_read": false ,
                "name" :  name
            ]
            
    
            
            currentMessages.append(newMessageEntry)
            
            
            strongSelf.database.child("conversations/\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }

                strongSelf.database.child("users/\(user!.uid)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]

                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0

                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }

                        if var targetConversation = targetConversation {
                            targetConversation["latestMessage"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "otherUserUID": otherUserUID ,
                                "name": name,
                                "latestMessage": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "otherUserUID": otherUserUID,
                            "name": name,
                            "latestMessage": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }

                    strongSelf.database.child("users/\(user!.uid)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }


                        // Update latest message for recipient user

                        strongSelf.database.child("users/\(otherUserUID)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryConversations = [[String: Any]]()

                            guard let currentName = Auth.auth().currentUser?.displayName else {
                                return
                            }

                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                var position = 0

                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }

                                if var targetConversation = targetConversation {
                                    targetConversation["latestMessage"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    // failed to find in current colleciton
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "otherUserUID": otherUserUID,
                                        "name": currentName,
                                        "latestMessage": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            }
                            else {
                                // current collection does not exist
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "otherUserUID": otherUserUID,
                                    "name": currentName,
                                    "latestMessage": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }

                            strongSelf.database.child("users/\(otherUserUID)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }

                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
}

struct ChatAppUser {
    let uid: String
    let displayName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}


