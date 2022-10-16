//  UserModel.swift
//  ECard

import Foundation
import RealmSwift

class Profile: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var owner_id: String?
    @Persisted var firstName: String?
    @Persisted var lastName: String?
    @Persisted var email: String?
    @Persisted var friends: List<String>
    
    convenience init(owner_id: String) {
        self.init()
        self.owner_id = owner_id
    }
}

struct UserProfile {
    let userID: String
    let email: String
    let firstName: String
    let lastName: String
    let profilePicture: ObjectId
    var friends: [UserProfile]
    let profileDetail: ProfileDetail
    var currentTitle: String
    var bio: String
    
    init(userID: String, email: String, firstName: String, lastName: String, profilePicture: ObjectId, friends: [UserProfile], profileDetail: Document, currentTitle: String, bio: String) {
        self.userID = userID
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.friends = friends
        self.profilePicture = profilePicture
        
        
        let phone = (profileDetail["phone"] as? AnyBSON)?.stringValue ?? ""
        let email = (profileDetail["email"] as? AnyBSON)?.stringValue ?? ""
        let playlist = (profileDetail["playlist"] as? AnyBSON)?.stringValue ?? ""
        let link = (profileDetail["link"] as? AnyBSON)?.stringValue ?? ""
        
        let profile = ProfileDetail(phone: phone, email: email, playlist: playlist, link: link)
        
        self.profileDetail = profile
        
        self.currentTitle = currentTitle
        self.bio = bio
    }
}

class ProfileDetail: NSObject {
    @objc var phone: String
    @objc var email: String
    @objc var playlist: String
    @objc var link: String
    
    init(phone: String, email: String, playlist: String, link: String) {
        self.phone = phone
        self.email = email
        self.playlist = playlist
        self.link = link
    }
}
