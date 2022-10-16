//  ViewController.swift
//  ECard

import UIKit
import MultipeerConnectivity
import RealmSwift

class ViewController: UIViewController, ConnectionManagerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var accountManager: AccountManager?
    var connectionManager = ConnectionManager()
    
    var friendList: [UserProfile] = []
    
    var imagePicker = UIImagePickerController()
    
    var userID = ""
    let appID = "application-0-zzyrs"
    
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connectionManager.delegate = self
        accountManager?.delegate = self
        
        if let currentUser = accountManager?.getCurrentUserProfile() {
            label.text = "\(currentUser.firstName) \(currentUser.lastName)"
            
            jobTitleLabel.text = currentUser.currentTitle
            bioLabel.text = currentUser.bio
            
            print(currentUser.profilePicture)
            ImageProcessor.getImage(imageID: currentUser.profilePicture, imageView: profileImageView)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        friendList = accountManager?.getCurrentUserProfile()?.friends ?? []
        
        let nib = UINib(nibName: "UserCell", bundle: nil)
        friendTableView.register(nib, forCellReuseIdentifier: "UserCell")
        
        friendTableView.dataSource = self
        friendTableView.delegate = self
        
        profileImageView.makeRounded()
    }
        
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if (motion == .motionShake) {
            connectionManager.activate(id: userID)
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { () in
                timer.invalidate()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: { () in
                self.connectionManager.deactivate()
                print(self.connectionManager.session.connectedPeers)
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func receivedUserID(id: String) {
        DispatchQueue.main.async {
            self.accountManager?.getProfile(userID: id)
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        // Your action
        showImageAction()
    }
    
    func showImageAction() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let changeProfileAction: UIAlertAction = UIAlertAction(title: "Change Profile Photo", style: .default) { action -> Void in
            self.showImagePicker()
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(changeProfileAction)
        actionSheetController.addAction(cancelAction)


        // present an actionSheet...
        // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad

        actionSheetController.popoverPresentationController?.sourceView = self.view // works for both iPhone & iPad

        present(actionSheetController, animated: true)
    }
    
    func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            let data = pickedImage.jpegData(compressionQuality: 0.5)!

            if (Float(Double(data.count)/1024/1024) > 5.0) {
                showAlert(message: "Image size greater than 5MB")
            }
            else {
                self.profileImageView.image = pickedImage
            }
        }
        else if let pickedImage = info[.originalImage] as? UIImage {
            let data = pickedImage.jpegData(compressionQuality: 0.5)!
            
            print(Float(Double(data.count)/1024/1024))
            
            if (Float(Double(data.count)/1024/1024) > 5.0) {
                showAlert(message: "Image size greater than 5MB")
            }
            else {
                self.profileImageView.image = pickedImage
            }
            ImageProcessor.updateImage(imageString: ImageProcessor.imageToBase64(image: pickedImage)!, userID: self.userID)
        }
        
        self.dismiss(animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            self.profileImageView.image = image
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showFriendList") {
            let destination = segue.destination as! FriendListViewController
            
            destination.friendList = self.friendList
        }
        else if (segue.identifier == "showFriendProfile") {
            let destination = segue.destination as! DiscoveredProfileViewController
            
            if let sender = sender as? IndexPath {
                destination.cachedProfilePicture = (friendTableView.cellForRow(at: sender) as! UserCell).profilePictureView.image
                
                destination.accountManager = self.accountManager
                destination.userProfile = friendList[sender.row]
            }
        }
        else if (segue.identifier == "showDiscoveredProfile") {
            let destination = segue.destination as! DiscoveredProfileViewController
            
            destination.accountManager = self.accountManager
            destination.userProfile = self.accountManager?.lastReadUserProfile
            
            self.connectionManager = ConnectionManager()
            connectionManager.delegate = self
        }
        else if (segue.identifier == "showEditView") {
            let destination = segue.destination as! EditLinkViewController
            
            guard let key = sender as? String else { return }
            
            destination.key = key
            destination.accountManager = self.accountManager
            destination.currentValue = self.accountManager?.getCurrentUserProfile()?.profileDetail.value(forKey: key) as? String
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        if (!self.connectionManager.isActive) {
            Task {
                await self.accountManager?.logOut()
            }
            
            self.performSegue(withIdentifier: "unwindToLogIn", sender: self)
        }
    }
    
    
    @IBAction func callButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditView", sender: "phone")
    }
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditView", sender: "email")
    }
    
    @IBAction func musicButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showEditView", sender: "playlist")
    }
    
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showEditView", sender: "link")
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userProfile = friendList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        cell.nameLabel.attributedText = attributedString(from: "\(userProfile.firstName) \(userProfile.lastName)", nonBoldRange: NSMakeRange(0, userProfile.firstName.count))
        
        cell.loadImage(imageID: userProfile.profilePicture)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showFriendProfile", sender: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let nonBoldAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
        ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
}

extension ViewController: AccountManagerDelegate {
    func loginSuccess(userID: String) {
        
    }
    
    func loginFailed(message: String) {
        
    }
    
    func registerSuccess(userID: String) {
        
    }
    
    func registerFailed(message: String) {
        
    }
    
    func userObtained(userProfile: UserProfile) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showDiscoveredProfile", sender: self)
        }
    }
}

extension UIImageView {
    
    func makeRounded() {
        layer.masksToBounds = false
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}
