//  EditLinkViewController.swift
//  ECard

import UIKit

class EditLinkViewController: UIViewController {
    var key: String?
    var accountManager: AccountManager?
    var currentValue: String?
    
    @IBOutlet weak var valueTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (key == "phone") {
            valueTextField.keyboardType = .numberPad
        }
        
        if let placeholder = currentValue {
            valueTextField.placeholder = placeholder }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        guard let newKey = key else { return }
        guard let newInfo = valueTextField.text else { return }
        
        if (!newInfo.isEmpty) {
            accountManager?.updateInfo(key: newKey, newInfo: newInfo)
        }
        
        self.dismiss(animated: true)
    }
}
