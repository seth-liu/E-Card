//  ImageProcessor.swift
//  ECard

import Foundation
import UIKit
import RealmSwift

class ImageProcessor {
    init() {
        
    }
    
    func imageToBinary() {
        
    }
    
    static func base64ToImage(imageString: String) -> UIImage? {
        if let imageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    static func imageToBase64(image: UIImage) -> String? {
        let imageData = image.jpegData(compressionQuality: 0.5)
        return imageData?.base64EncodedString(options: .lineLength64Characters)
    }
    
    static func updateImage(imageString: String, userID: String) {
        let app = App(id: "application-0-zzyrs")
        
        let userClient = app.currentUser!.mongoClient("mongodb-atlas")
        let database = userClient.database(named: "UserInfo")
        let collection = database.collection(withName: "Images")
        
        let newDocument: Document = ["imageString": AnyBSON.string(imageString), "owner_id": AnyBSON.string(userID)]
        
        collection.insertOne(newDocument) { (result) in
            switch result {
                case .failure(let error):
                    print("Failed to insert document: \(error.localizedDescription)")
                case .success(let newObjectId):
                    print("Inserted document with object ID: \(newObjectId)")
                    let userCollection = database.collection(withName: "Profile")
                    userCollection.updateOneDocument(filter: ["owner_id": AnyBSON.string(userID)], update: ["$set": ["profilePicture": newObjectId]]) { (result) in return}
            }
        }
    }
    
    static func getImage(imageID: ObjectId, imageView: UIImageView) {
        let app = App(id: "application-0-zzyrs")
        
        let userClient = app.currentUser!.mongoClient("mongodb-atlas")
        let database = userClient.database(named: "UserInfo")
        let collection = database.collection(withName: "Images")
        
        collection.findOneDocument(filter: ["_id": AnyBSON.objectId(imageID)]) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    return
                case .success(let document):
                    DispatchQueue.main.async {
                        if let imageString = document?["imageString"] {
                            imageView.image = ImageProcessor.base64ToImage(imageString: (imageString?.stringValue)!)
                        }
                    }
            }
        }
    }
}
