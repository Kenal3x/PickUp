//
//  gameManager.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 8/4/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore
import UIKit


final class gameManager {
    static let shared = gameManager()
    

}

struct userData {
    static let sharedInstance = userData()
    
    func getUserData(userID: String ,completion: @escaping (User) -> ()) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if error != nil {
                print(error?.localizedDescription)
            }
            if let document = document , document.exists {
                let userData = User.init(userDocument: document.data()!, documentID: document.documentID)
                completion(userData)
            }
        
        }
    }
}

extension gameManager {
    public func getUserInfo (onSuccess: @escaping () -> Void, onError: @escaping (_ error: Error?)-> Void) {
        
    }
    
    //creates a gane function
//    public func createGame(gameData: basicGame , userData: User) {
//        let db = Firestore.firestore()
//        let batch = db.batch()
//
//
//        //User Joins the game, adds the user into the current list of users
//        let  userUpcomingDoc = db.collection("users").document(user!.uid)
//        batch.setData(["upcomingGame" : ["gameID" : gameData.ID , "gameTimeStamp" : FieldValue.serverTimestamp() , "participated" : false , "role" : "owner"]], forDocument: userUpcomingDoc, merge: true)
//
//
//        //adds the user to the list of current users, since the guy is a creator his role will be an owner
//        let userListDoc = db.collection("publicGameDoc").document(gameData.ID)
//        batch.setData(["creation" : FieldValue.serverTimestamp() , "owner" : user!.uid , "ballID" : "" , "userList" : [user!.uid : ["displayName" : user?.displayName , "role" : "owner" , "uid" : user?.uid , "ppURL" : user?.photoURL?.absoluteString]]], forDocument: userListDoc , merge: true)
//
//        batch.commit() { err in
//            if let err = err {
//                print("Error writing batch \(err)")
//            } else {
//                print("Batch write succeeded.")
//            }
//        }
//
//    }
    
    public func joinGame(gameDocID: String , userData: User) {
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        //sets the user's upcoming Data, and overwrites the fields
        let  userUpcomingDoc = db.collection("users").document(user!.uid)
        batch.setData(["upcomingGame" : ["gameID" : gameDocID , "gameTimeStamp" : FieldValue.serverTimestamp() , "participated" : false , "role" : "member"]], forDocument: userUpcomingDoc, merge: true)
        
        //adds the game to the user's list of games
        
        
        //adds the user to the list of current users, since the guy is a member his role will be an member
        let userListDoc = db.collection("publicGameDoc").document(gameDocID)
        batch.setData(["userList" : [user?.uid : ["displayName" : user?.displayName , "role" : "member" , "ppURL" : user?.photoURL?.absoluteString , "uid" : user?.uid]]], forDocument: userListDoc , merge: true)
            

        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
        
    }
    
//    public func loadPublicData(gameID : String, completion: @escaping (gamePublicData) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("publicGameDoc").document(gameID).addSnapshotListener { document, error in
//            if error != nil {
//                print(error?.localizedDescription)
//            }
//            if let document = document , document.exists {
//                var publicData = gamePublicData.init(gameDocument: document.data()!, documentID: document.documentID)
//                completion(publicData)
//
//            } else {
//                print("game doesnt exist")
//            }
//
//
//        }
//    }
    
    
}



