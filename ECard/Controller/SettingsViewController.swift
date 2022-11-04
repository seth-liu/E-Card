//  SettingsViewController.swift
//  ECard

import UIKit

class SettingsViewController: UITableViewController {
    var accountManager: AccountManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            Task {
                await accountManager?.logOut()
            }
            
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }
    }
}
