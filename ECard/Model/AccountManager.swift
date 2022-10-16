//  LoginManager.swift
//  ECard

import Foundation
import RealmSwift
import UIKit

protocol AccountManagerDelegate {
    func loginSuccess(userID: String)
    func loginFailed(message: String)
    func registerSuccess(userID: String)
    func registerFailed(message: String)
    func userObtained(userProfile: UserProfile)
}

class AccountManager {
    let appID = "application-0-zzyrs"
    let app: App
    
    var delegate: AccountManagerDelegate?
    
    var userProfile: UserProfile?
    var lastReadUserProfile: UserProfile?
    
    init() {
        app = App(id: appID)
    }
    
    func login(username: String, password: String) {
        app.login(credentials: Credentials.emailPassword(email: username, password: password)) { [self] (result) in
            switch result {
                case .failure(let error):
                    self.delegate?.loginFailed(message: error.localizedDescription)
                case .success(let user):
                    print("Successfully logged in as user \(user)")
                    // Now logged in, do something with user
                    // Remember to dispatch to main if you are doing anything on the UI thread
                        
                    let userID = (user.customData["owner_id"] as? AnyBSON)?.stringValue ?? ""
                    let email = (user.customData["email"] as? AnyBSON)?.stringValue ?? ""
                    let firstName = (user.customData["firstName"] as? AnyBSON)?.stringValue ?? ""
                    let lastName = (user.customData["lastName"] as? AnyBSON)?.stringValue ?? ""
                    let friends = (user.customData["friends"] as? AnyBSON)?.arrayValue ?? []
                    let profilePicture = (user.customData["profilePicture"] as? AnyBSON)?.objectIdValue ?? ObjectId.init()
                    let friendsString: [String] = friends.map({ $0?.stringValue ?? "" })
                    let profileDetail = (user.customData["profileDetail"] as? AnyBSON)?.documentValue ?? Document()
                    let currentTitle = (user.customData["currentTitle"] as? AnyBSON)?.stringValue ?? ""
                    let bio = (user.customData["bio"] as? AnyBSON)?.stringValue ?? ""
                
                    print(profileDetail)
                

                self.userProfile = UserProfile(userID: userID, email: email, firstName: firstName, lastName: lastName, profilePicture: profilePicture, friends: [], profileDetail: profileDetail, currentTitle: currentTitle, bio: bio)
                    
                    convertFriendListToUserProfile(friendUserID: friendsString)
            }
        }
    }
    
    func register(username: String, password: String, firstName: String, lastName: String) async {
        let app = App(id: appID)
        let client = app.emailPasswordAuth
        
        do {
            try await client.registerUser(email: username, password: password)
            
            // Registering just registers. You can now log in.
            print("Successfully registered user.")
            
            app.login(credentials: Credentials.emailPassword(email: username, password: password)) { (result) in
                switch result {
                    case .failure(let error):
                        print("Login failed: \(error.localizedDescription)")
                    case .success(let user):
                        print("Successfully logged in as user \(user)")
                        // Now logged in, do something with user
                        // Remember to dispatch to main if you are doing anything on the UI thread
                        let userClient = user.mongoClient("mongodb-atlas")
                        let database = userClient.database(named: "UserInfo")
                        let collection = database.collection(withName: "Profile")
                    
                        // Insert the custom user data object
                        collection.insertOne([
                            "firstName": AnyBSON(firstName),
                            "lastName": AnyBSON(lastName),
                            "email": AnyBSON(username),
                            "owner_id": AnyBSON(user.id),
                            "friends": AnyBSON([]),
                            "profilePicture": AnyBSON(ObjectId()),
                            "profileDetail": AnyBSON(["phone": "", "email": "", "playlist": "", "link": ""]),
                            "currentTitle": "Current Title",
                            "bio": "Bio"
                            ]) { (result) in
                                switch result {
                                case .failure(let error):
                                    print("Failed to insert document: \(error.localizedDescription)")
                                case .success(let newObjectId):
                                    print("Inserted custom user data document with object ID: \(newObjectId)")
                        }
                        self.delegate?.registerSuccess(userID: user.id)
                    }
                }
            }
        } catch {
            self.delegate?.registerFailed(message: error.localizedDescription)
        }
    }
    
    func getProfile(userID: String) {
        let queryFilter: Document = ["owner_id": AnyBSON.string(userID)]
        
        let client = app.currentUser!.mongoClient("mongodb-atlas")
        let database = client.database(named: "UserInfo")
        let collection = database.collection(withName: "Profile")

        collection.findOneDocument(filter: queryFilter) { result in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    return
                case .success(let document):
                    guard let safeDocument = document else { return }
                            
                    let userID = (safeDocument["owner_id"] as? AnyBSON)?.stringValue ?? ""
                    let email = (safeDocument["email"] as? AnyBSON)?.stringValue ?? ""
                    let firstName = (safeDocument["firstName"] as? AnyBSON)?.stringValue ?? ""
                    let lastName = (safeDocument["lastName"] as? AnyBSON)?.stringValue ?? ""
                    let profilePicture = (safeDocument["profilePicture"] as? AnyBSON)?.objectIdValue ?? ObjectId.init()
                    let profileDetail = (safeDocument["profileDetail"] as? AnyBSON)?.documentValue ?? Document()
                    let currentTitle = (safeDocument["currentTitle"] as? AnyBSON)?.stringValue ?? ""
                    let bio = (safeDocument["bio"] as? AnyBSON)?.stringValue ?? ""
                    
                let userProfile = UserProfile(userID: userID, email: email, firstName: firstName, lastName: lastName, profilePicture: profilePicture, friends: Array<UserProfile>(), profileDetail: profileDetail, currentTitle: currentTitle, bio: bio)
                    
                    self.lastReadUserProfile = userProfile
                
                    self.delegate?.userObtained(userProfile: userProfile)
            }
        }
    }
    
    func getCurrentUserProfile() -> UserProfile? {
        return self.userProfile
    }
    
    func convertFriendListToUserProfile(friendUserID: [String]) {
        let queryFilter: Document = ["owner_id": ["$in": AnyBSON.array( friendUserID.map({ AnyBSON($0) }))]]
        let queryOptions = FindOptions(limit: nil, projection: nil, sort: ["lastName": 1, "firstName": 1])
        
        let client = app.currentUser!.mongoClient("mongodb-atlas")
        let database = client.database(named: "UserInfo")
        let collection = database.collection(withName: "Profile")
        
        collection.find(filter: queryFilter, options: queryOptions) { result in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    return
                case .success(let documents):
                    for document in documents {
                        let userID = (document["owner_id"] as? AnyBSON)?.stringValue ?? ""
                        let email = (document["email"] as? AnyBSON)?.stringValue ?? ""
                        let firstName = (document["firstName"] as? AnyBSON)?.stringValue ?? ""
                        let lastName = (document["lastName"] as? AnyBSON)?.stringValue ?? ""
                        let profilePicture = (document["profilePicture"] as? AnyBSON)?.objectIdValue ?? ObjectId.init()
                        let profileDetail = (document["profileDetail"] as? AnyBSON)?.documentValue ?? Document()
                        let currentTitle = (document["currentTitle"] as? AnyBSON)?.stringValue ?? ""
                        let bio = (document["bio"] as? AnyBSON)?.stringValue ?? ""
                        
                        let userProfile = UserProfile(userID: userID, email: email, firstName: firstName, lastName: lastName, profilePicture: profilePicture, friends: Array<UserProfile>(), profileDetail: profileDetail, currentTitle: currentTitle, bio: bio)

                        self.userProfile?.friends.append(userProfile)
                    }
                
                self.delegate?.loginSuccess(userID: self.app.currentUser!.id)
            }
        }
    }
    
    func addFriend(friend: UserProfile) {
        let queryFilter: Document = ["owner_id": AnyBSON(self.userProfile!.userID)]
        
        let documentUpdate: Document = ["$push": ["friends": AnyBSON(friend.userID)]]
        
        let client = app.currentUser!.mongoClient("mongodb-atlas")
        let database = client.database(named: "UserInfo")
        let collection = database.collection(withName: "Profile")
        
        collection.updateOneDocument(filter: queryFilter, update: documentUpdate) { result in
            switch result {
            case .failure(let error):
                print("Failed to update document: \(error.localizedDescription)")
                return
            case .success(let updateResult):
                if (updateResult.matchedCount == 1 && updateResult.modifiedCount == 1) {
                    print("Successfully updated a matching document.")
                    self.userProfile?.friends.append(friend)
                    
                } else {
                    print("Did not update a document")
                }
            }
        }
    }
    
    func updateInfo(key: String, newInfo: String) {
        guard let currentProfile = self.getCurrentUserProfile() else { return }
        
        let queryFilter: Document = ["owner_id": AnyBSON(currentProfile.userID)]
        
        let documentUpdate: Document = ["$set": ["profileDetail.\(key)": AnyBSON(newInfo)]]
        
        let client = app.currentUser!.mongoClient("mongodb-atlas")
        let database = client.database(named: "UserInfo")
        let collection = database.collection(withName: "Profile")
        
        
        collection.updateOneDocument(filter: queryFilter, update: documentUpdate) { result in
            switch result {
            case .failure(let error):
                print("Failed to update document: \(error.localizedDescription)")
                return
            case .success(let updateResult):
                if (updateResult.matchedCount == 1 && updateResult.modifiedCount == 1) {
                    
                    self.getCurrentUserProfile()?.profileDetail.setValue(newInfo, forKey: key)
                    
                    print("Successfully updated a matching document.")
                } else {
                    print("Did not update a document")
                }
            }
        }
    }
    
    func getInfo(userID: String, key: String, url: String) {
    
        let queryFilter: Document = ["owner_id": AnyBSON(userID)]
        
        let client = app.currentUser!.mongoClient("mongodb-atlas")
        let database = client.database(named: "UserInfo")
        let collection = database.collection(withName: "Profile")
        
        collection.findOneDocument(filter: queryFilter) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                return
            case .success(let document):
                guard let safeDocument = document else { return }
                
                let profileDetail = (safeDocument["profileDetail"] as? AnyBSON)?.documentValue ?? Document()
                
                let value = (profileDetail[key] as? AnyBSON)?.stringValue ?? ""
                
                let url = URL(string: "\(url)\(value)")!
                
                print(url)
                
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func logOut() async {
        do {
            try await app.currentUser?.logOut()
        } catch {
            print(error.localizedDescription)
        }
    }
}
