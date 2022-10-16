//  LoginViewController.swift
//  ECard

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    var accountManager = AccountManager()
    
    var userID: String = ""
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()

    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()

    /// Text shown during load the TableView
    let loadingLabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountManager.delegate = self
        
        setLoadingScreen()
        
        passwordField.enablePasswordToggle()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = usernameField.text else { return }
        guard let password = passwordField.text else { return }
        
        showLoadingScreen()
        
        accountManager.login(username: email, password: password)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showUserInterface") {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.topViewController as! ViewController
            
            destination.userID = self.userID
            self.accountManager.delegate = nil
            destination.accountManager = self.accountManager
        }
    }
    
    private func setLoadingScreen() {

        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 200
        let height: CGFloat = 150
        
        let x = (self.view.frame.width / 2) - (width / 2)
        let y = (self.view.frame.height / 2) - (height / 2)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

        // Sets loading text
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 50, y: 60, width: 140, height: 30)

        // Sets spinner
        spinner.style = .medium
        spinner.frame = CGRect(x: 10, y: 60, width: 30, height: 30)

        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        loadingView.layer.borderWidth = 1.0
        loadingView.backgroundColor = UIColor(red: CGFloat(236.0/255.0), green: CGFloat(228.0/255.0), blue: CGFloat(205.0/255.0), alpha: 1)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        loadingView.layer.masksToBounds = false
        
        self.view.addSubview(loadingView)
        
        loadingView.isHidden = true
        
    }

    func showLoadingScreen() {
        loadingView.isHidden = false
        self.view.isUserInteractionEnabled = false
        spinner.startAnimating()
    }
    
    private func removeLoadingScreen() {

        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        loadingView.isHidden = true
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        self.accountManager = AccountManager()
        accountManager.delegate = self
    }
}

extension LoginViewController: AccountManagerDelegate {
    func loginSuccess(userID: String) {
        self.userID = userID
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showUserInterface", sender: self)
            self.removeLoadingScreen()
        }
    }
    
    func loginFailed(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.removeLoadingScreen()
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func registerSuccess(userID: String) {
        
    }
    
    func registerFailed(message: String) {
        
    }
    
    func userObtained(userProfile: UserProfile) {
        
    }
}

extension UITextField {
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry){
            button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }else{
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
    }

    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}
