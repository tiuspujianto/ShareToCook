//
//  SettingTableViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 11/6/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "signOutCell", for: indexPath) as! SettingTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath) as! SettingTableViewCell
        return cell

    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // This function is for sign out a user from the firebase.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            do {
                try Auth.auth().signOut()
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "WelcomePage") as UIViewController
                self.present(viewController, animated: true, completion: nil)
                
            }
            catch let err {
                print (err)
            }
        }

    }
}
