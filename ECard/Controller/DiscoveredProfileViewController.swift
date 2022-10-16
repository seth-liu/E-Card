//  DiscoveredProfileViewController.swift
//  ECard

import UIKit

class DiscoveredProfileViewController: UIViewController {
    
    var userProfile: UserProfile?
    var cachedProfilePicture: UIImage?
    
    var accountManager: AccountManager?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var profileActionButton: UIButton!
    @IBOutlet weak var friendActionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let safeUserProfile = userProfile {
            nameLabel.text = "\(safeUserProfile.firstName) \(safeUserProfile.lastName)"
            emailLabel.text = safeUserProfile.email
        }
        
        if let image = cachedProfilePicture {
            profilePictureView.image = image
        }
        else if let imageID = userProfile?.profilePicture {
            ImageProcessor.getImage(imageID: imageID, imageView: profilePictureView)
        }
        
        profilePictureView.makeRounded()
        
        if (accountManager?.userProfile?.friends.contains(where: { $0.userID == userProfile?.userID }) != nil) {
            friendActionButton.setTitle("Remove Friend", for: .normal)
        }
    }
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
        guard let userID = userProfile?.userID else { return }
        
        accountManager?.getInfo(userID: userID, key: "phone", url: "tel://")
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        guard let userID = userProfile?.userID else { return }
        
        accountManager?.getInfo(userID: userID, key: "email", url: "mailto:")
    }
    
    @IBAction func addFriendButtonPressed(_ sender: UIButton) {
        accountManager?.addFriend(friend: userProfile!)
    }
}
