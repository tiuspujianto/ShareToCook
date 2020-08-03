//
//  WelcomePageViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 5/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Firebase

class WelcomePageViewController: UIViewController, UITextFieldDelegate {
    
    var authController: Auth = Auth.auth()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func logInButtonHandler(_ sender: Any) {
        // Prompt to log in to the firebase authentication
        authController.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {(authResult, error) in
            guard authResult != nil else {
                let displayMessage = DisplayMessage(title: "Log in failed", msg: "Please check your email and password")
                self.present(displayMessage.alertController, animated: true, completion: nil)
                return
            }
            // Create a variable to indicate that a user has logged in
            let preferences = UserDefaults.standard
            preferences.set(true, forKey: "status")
            let database = Firestore.firestore()
            database.collection("user").getDocuments {(querySnapshot, err) in
                if let err = err {
                    print ("Error getting documents: \(err)")
                }else{
                    for document in querySnapshot!.documents {
                        if document.data()["email"] as? String == self.emailTextField.text{
                            let user = User()
                            user.description = document.data()["description"] as! String
                            user.email = document.data()["email"] as! String
                            user.username = document.data()["username"] as! String
                            user.name = document.data()["name"] as! String
                            user.id = document.documentID
                            user.favouriteCategory = document.data()["favourite"] as! [String]
                
                            preferences.set(user.username, forKey: "username")
                            preferences.set(user.name, forKey: "name")
                            preferences.set(user.email, forKey: "email")
                            preferences.set(user.description, forKey: "description")
                            preferences.set(user.id, forKey: "userID")
                            preferences.set(user.favouriteCategory, forKey: "favouriteCategory")
                        }
                    }
                }
            }
            
            preferences.synchronize()
            // create a user data in preferences
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "homeMainTabBarController") as UIViewController
            self.present(viewController, animated: true, completion: nil)
        }
    }
}
