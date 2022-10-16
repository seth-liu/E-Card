//  RegisterViewController.swift
//  ECard

import UIKit
import RealmSwift

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    let accountManager = AccountManager()
    
    let appID = "application-0-zzyrs"
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    var userID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        
        accountManager.delegate = self
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard let email = usernameField.text else { return }
        guard let password = passwordField.text else { return }
        guard let firstName = firstNameField.text else { return }
        guard let lastName = lastNameField.text else { return }
        
        Task {
            await accountManager.register(username: email, password: password, firstName: firstName, lastName: lastName)
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showUserInterfaceFromRegister") {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.topViewController as! ViewController
            
            destination.userID = userID ?? ""
            self.accountManager.delegate = nil
            destination.accountManager = self.accountManager
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}

extension RegisterViewController: AccountManagerDelegate {
    func loginSuccess(userID: String) {
    }
    
    func loginFailed(message: String) {
    }
    
    func registerSuccess(userID: String) {
        self.userID = userID
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showUserInterfaceFromRegister", sender: self)
        }
    }
    
    func registerFailed(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func userObtained(userProfile: UserProfile) {
        
    }
}
