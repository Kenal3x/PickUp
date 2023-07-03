//
//  User.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/28/21.
//

import Foundation
import FirebaseFirestore



class User {
    var name: String
    var displayName : String
    var userID : String
    var age: Int
    var created: Date
    var gender: String
    var sport: String
    var sportLevel: String
    var email: String
    var imageURL: String
    var onboarding: Bool
    var validGamesMap: [String : [String: Any]]
    var upcomingGamesMap: [String: [String : Any]]
    var userGames: [String] = []
    var state: String
    var upcomingGames: [UpcomingGame] = []
    var validGames: [ValidGame] = []
    var creationDateString: String {
        let formatter = DateFormatter ()
        formatter.dateFormat =  "MM/dd/yyyy"
        return formatter.string(from: created)
    }
    
    
    init(name: String ,displayName : String , userID: String, age: Int , created: Date , gender: String , sportLevel: String , email: String , sport: String, imageURL: String , validGamesMap: [String : [String: Any]] , userGames : [String] , onboarding: Bool , state: String , upcomingGames: [UpcomingGame] , upcomingGamesMap : [String: [String:Any]]) {
        self.name = name
        self.sport = sport
        self.displayName = displayName
        self.userID = userID
        self.age = age
        self.created = created
        self.gender = gender
        self.sportLevel = sportLevel
        self.email = email
        self.imageURL = imageURL
        self.validGamesMap = validGamesMap
        self.userGames = userGames
        self.onboarding = onboarding
        self.state = state
        self.upcomingGames = upcomingGames
        self.upcomingGamesMap = upcomingGamesMap
        
    }

    init(userDocument: [String: Any], documentID: String ) {
        self.name = userDocument[""] as? String ?? ""
        self.displayName = userDocument["displayName"] as? String ?? ""
        self.userID = userDocument["uid"] as? String ?? ""
        self.age = userDocument["age"] as? Int ?? 0
        self.email = userDocument["email"] as? String ?? ""
        self.created = (userDocument["created"] as? Timestamp)?.dateValue() ?? Date()
        self.sportLevel = userDocument["sportLevel"] as? String ?? "rookie"
        self.gender = userDocument["gender"] as? String ?? "Not Listed"
        self.sport = userDocument["sport"] as? String ?? "Not Listed"
        self.imageURL = userDocument["imageURL"] as? String ?? ""
        self.validGamesMap = userDocument["validGames"] as? [String: [String: Any]] ?? [:]
        self.onboarding = userDocument["onboardingComplete"] as? Bool ?? false
        self.state = userDocument["state"] as? String ?? ""
        self.upcomingGamesMap = userDocument["upcomingGame"] as? [String : [String:Any]] ?? [:]
        
        for validGameMap in validGamesMap {
           
            
            //for now we are not counting any of the extra data like date
            let validGame = ValidGame.init(validGame: validGameMap.value, documentID: validGameMap.key)
            validGames.append(validGame)
            
            
        }
        
        for upcomingGameMap in upcomingGamesMap  {
            let upcomingGame = UpcomingGame.init(upcomingGame: upcomingGameMap.value ,documentID: upcomingGameMap.key)
            
            upcomingGames.append(upcomingGame)
        }
    }
    
    // this is for iniatilizing from a game doc
    
    
}

class OtherUser {
    var role: String
    var name:  String
    var userID: String
    var userpp: String
    
    init(role: String, name: String , userID: String , userpp: String){
        self.role = role
        self.name = name
        self.userID = userID
        self.userpp = userpp
    }
    
    init(userMap : [String: Any], documentID: String) {
        self.role = userMap["role"] as? String ?? ""
        self.name = userMap["name"] as? String ?? ""
        self.userID = documentID
        self.userpp = userMap["ppURL"] as? String ?? ""
        
    }
}

class UpcomingGame {
    var gameID: String
    var title: String
    var locationOfGame: String
    var nameOfGame: String
    var sport: String
    var amountOfPlayers: Int
    
    var gameTimeStamp: Date
    var participated: Bool
    var location: GeoPoint
    var role: String
    
    init(gameID: String , gameTimeStamp: Date , participated: Bool , role: String , location: GeoPoint , title: String , locationOfGame: String , nameOfGame:String , sport:String  , amountOfPlayers: Int) {
        self.gameID = gameID
        self.gameTimeStamp = gameTimeStamp
        self.participated = participated
        self.role = role
        self.location = location
        
        self.title = title //this is the name of the place according to google maps
        self.locationOfGame = locationOfGame //this is the address of the place given by google maps
        self.nameOfGame = nameOfGame
        self.sport = sport
        self.amountOfPlayers = amountOfPlayers
        
    }
    
    init(upcomingGame : [String: Any] , documentID: String) {
        self.gameID = upcomingGame["gameID"] as? String ?? ""
        self.gameTimeStamp = (upcomingGame["created"] as? Timestamp)?.dateValue() ?? Date()
        self.participated = upcomingGame["participated"] as? Bool ?? false
        self.role = upcomingGame["role"] as? String ?? "member"
        self.location = upcomingGame["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.locationOfGame = upcomingGame["locationOfGame"] as? String ?? ""
        self.sport = upcomingGame["sport"] as? String ?? ""
        self.nameOfGame = upcomingGame["nameOfGame"] as? String ?? ""
        self.amountOfPlayers = upcomingGame["amountOfPlayers"] as? Int ?? 22
        self.title = upcomingGame["title"] as? String ?? ""
        
    }
}


class ValidGame {
    var gameID: String
    var title: String
    var locationOfGame: String
    var nameOfGame: String
    var sport: String
    var amountOfPlayers: Int
    
    var gameTimeStamp: Date
    var participated: Bool
    var location: GeoPoint
    var role: String
    
    init(gameID: String , gameTimeStamp: Date , participated: Bool , role: String , location: GeoPoint , title: String , locationOfGame: String , nameOfGame:String , sport:String  , amountOfPlayers: Int) {
        self.gameID = gameID
        self.gameTimeStamp = gameTimeStamp
        self.participated = participated
        self.role = role
        self.location = location
        
        self.title = title //this is the name of the place according to google maps
        self.locationOfGame = locationOfGame //this is the address of the place given by google maps
        self.nameOfGame = nameOfGame
        self.sport = sport
        self.amountOfPlayers = amountOfPlayers
        
    }
    
    init(validGame : [String: Any] , documentID: String) {
        self.gameID = validGame["gameID"] as? String ?? ""
        self.gameTimeStamp = (validGame["created"] as? Timestamp)?.dateValue() ?? Date()
        self.participated = validGame["participated"] as? Bool ?? false
        self.role = validGame["role"] as? String ?? "member"
        self.location = validGame["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.locationOfGame = validGame["locationOfGame"] as? String ?? ""
        self.sport = validGame["sport"] as? String ?? ""
        self.nameOfGame = validGame["nameOfGame"] as? String ?? ""
        self.amountOfPlayers = validGame["amountOfPlayers"] as? Int ?? 22
        
        self.title = validGame["title"] as? String ?? ""
    }
        
}
    
