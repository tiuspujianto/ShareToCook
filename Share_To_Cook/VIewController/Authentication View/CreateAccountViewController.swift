//
//  CreateAccountViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 5/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnterPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        reEnterPasswordTextField.isSecureTextEntry = true
        
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
    
    @IBAction func signUpBtnHandler(_ sender: Any) {
        if passwordTextField.text != reEnterPasswordTextField.text {
            let displayMessage = DisplayMessage(title: "Password Didn't Match", msg: "Please check your password")
            self.present(displayMessage.alertController, animated: true, completion: nil)
        }
        // Creating an account in the firebase authentication
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (users, error) in
            if error == nil {
                Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {(authResult, error) in
                    guard authResult != nil else {
                        fatalError("Email or password did not match")
                    }
                    let preference = UserDefaults.standard
                    preference.set(self.emailTextField.text, forKey: "email")
                    preference.synchronize()
                    let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileNavigationController") as UIViewController
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
}
