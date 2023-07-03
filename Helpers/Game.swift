import FirebaseFirestore
import CoreLocation

class Owner  {
    var displayName : String
    var ppURL : String
    var uid : String
    
    init(displayName: String , ppURL: String , uid: String) {
        self.displayName = displayName
        self.ppURL = ppURL
        self.uid = uid
    }
    init(ownerDocument : [String: Any] , documentID: String) {
        self.displayName = ownerDocument["displayName"] as? String ?? ""
        self.ppURL = ownerDocument["ppURL"] as? String ?? ""
        self.uid = ownerDocument["uid"] as? String ?? ""
    }
}

class gameUserInfo {
    var displayName: String
    var role: String
    var ppURL: String
    var uid: String
    
    
    
    init(displayName : String , role: String, ppURL: String , uid: String) {
        self.displayName = displayName
        self.role = role
        self.ppURL = ppURL
        self.uid = uid
    }
    
    init(userListDictionary: [String : Any] , documentID: String) {
        self.displayName = userListDictionary["displayName"] as? String ?? ""
        self.role = userListDictionary["role"] as? String ?? ""
        self.ppURL = userListDictionary["ppURL"] as? String ?? ""
        self.uid = userListDictionary["uid"] as? String ?? ""
    }
}

//class gamePublicData {
//    var owner: String
//    var userMap: [String: [String: Any]]
//    var userList : [gameUserInfo] = []
//    var ballID: String
//
//
//    init(owner : String , userMap: [String: [String: Any]] , userList: [gameUserInfo] , ballID: String) {
//        self.owner = owner
//        self.userMap = userMap
//        self.userList = userList
//        self.ballID = ballID
//
//    }
//
//    init(gameDocument : [String : Any] , documentID: String) {
//        self.owner = gameDocument["owner"] as? String ?? ""
//        self.userMap = gameDocument["userList"] as? [String:[String: Any]] ?? [:]
//        self.ballID = gameDocument["ballID"] as? String ?? ""
//        for userM in userMap {
//            let user = gameUserInfo.init(userListDictionary: userM.value, documentID: userM.key)
//            userList.append(user)
//        }
//    }
//}

//class basicGame {
//    var title: String
//    var ID: String
//    var nameOfGame: String
//    var sport: String
//    var date: Date
//    var description:String
//    var based: String
//    var finishedGameCreation: Bool
//    var ownerName: String
//    var ownerID: String
//    var location: GeoPoint
//
//    init(title: String , ID: String, nameOfGame: String , sport: String , date: Date , description: String , based: String , finishedGameCreation: Bool , ownerName: String , ownerID: String , location: GeoPoint){
//
//        self.title = title
//        self.nameOfGame = nameOfGame
//        self.sport = sport
//        self.date = date
//        self.description = description
//        self.based = based
//        self.finishedGameCreation = finishedGameCreation
//        self.ownerName = ownerName
//        self.ownerID = ownerID
//        self.location = location
//        self.ID = ID
//    }
//}

class Game{
    
    var gameID: String
    var geoHash: GeoPoint
    var latitude: Double
    var longitude: Double
    var placeID: String
    var placeAddress: Address
    var placeAddressMap: [String: Any]
    var nameOfGame: String
    var descriptionOfGame: String
    var finishedGameCreation: Bool
    var dateCreated: Date
    var sport: String
    var date: Date
    var userMap: [String: [String : Any]] //used for getting users from game
    var userList : [OtherUser] = [] //used for getting users from game
    var gamePrivate: Bool
    var dateString: String {
        let formatter = DateFormatter ()
        formatter.dateFormat =  "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    ///this is used for the loading games screen
    var locationCoordinates: CLLocation {
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    ///this is used for annotations
    var locationCoordinatesAnnotations: CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    

    init (gameID: String , geoHash: GeoPoint , latitude: Double, longitude: Double, placeID: String, placeAdress: Address , placeAddressMap: [String:Any] , nameOfGame: String , descriptionOfGame: String , finishedGameCreation: Bool , dateCreated: Date , sport: String , date: Date , gamePrivate: Bool, userMap: [String: [String:Any]] , userList : [OtherUser] , dateString: String , timeString: String) {
        
        self.gameID = gameID
        self.geoHash = geoHash
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
        self.placeAddress = placeAdress
        self.placeAddressMap = placeAddressMap
        self.nameOfGame = nameOfGame
        self.descriptionOfGame = descriptionOfGame
        self.finishedGameCreation = finishedGameCreation
        self.dateCreated = dateCreated
        self.sport = sport
        self.date = date
        self.gamePrivate = gamePrivate
        self.userMap = userMap
        self.userList = userList
        
    }
    

    init(gameDocument: [String: Any], documentID: String ) {
        
        self.gameID = documentID
        self.geoHash = gameDocument["geoHash"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        self.latitude = gameDocument["latitude"] as? Double ?? 0.0
        self.longitude = gameDocument["longitutde"] as? Double ?? 0.0
        self.placeID = gameDocument["placeID"] as? String ?? ""
        self.placeAddressMap = gameDocument["placeAddress"] as? [String:Any] ?? [:]
        self.nameOfGame = gameDocument["nameOfGame"] as? String ?? ""
        self.descriptionOfGame = gameDocument["descriptionOfGame"] as? String ?? ""
        self.finishedGameCreation = gameDocument["finishedGameCreation"] as? Bool ?? false
        self.dateCreated = (gameDocument["dateCreated"] as? Timestamp)?.dateValue() ?? Date()
        self.sport = gameDocument["sport"] as? String ?? ""
        self.date = (gameDocument["date"] as? Timestamp)?.dateValue() ?? Date()
        self.placeAddress = Address.init(addressMap: placeAddressMap)
        self.gamePrivate = gameDocument["gamePrivate"] as? Bool ?? true
        self.userMap = gameDocument["userList"] as? [String: [String: Any]] ?? [:]
    
        for userM in userMap {
            let user = OtherUser.init(userMap: userM.value , documentID: userM.key)
            userList.append(user)
            
                
        }
        
        
      
        


    }
}


