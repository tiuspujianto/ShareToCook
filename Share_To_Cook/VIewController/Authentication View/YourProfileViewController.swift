//
//  YourProfileViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 6/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Firebase


class YourProfileViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    
    var email: String!
    var database: Firestore!
    var items: [String] = []
    var preferences: UserDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        descTextView.delegate = self
        setTextView()
        database = Firestore.firestore()
        database.collection("Category").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.items.append(document.get("name") as! String)
                }
            }
        }
        email = preferences.string(forKey: "email")
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func setTextView(){
        // Setting up the border of the text view
        descTextView.layer.cornerRadius = 10
        descTextView.layer.borderWidth = 0.1
        descTextView.clipsToBounds = true
        
        descTextView.text = "enter your description"
        descTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "enter your description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let newUser = User()
        var thereIsEmptyField = false
        var errorMsg = "Please fill the following field(s): "
        
        if (nameTextField.text == ""){
            errorMsg += "- Name\n"
            thereIsEmptyField = true
        }
        if (usernameTextField.text == ""){
            errorMsg += "- Username\n"
            thereIsEmptyField = true
        }
        if (descTextView.text == "" || descTextView.text == "enter your description"){
            errorMsg += "- Description\n"
            thereIsEmptyField = true
        }
        if thereIsEmptyField{
            let displayMessage = DisplayMessage(title: "Found empty text field: ", msg: errorMsg)
            self.present(displayMessage.alertController, animated: true, completion: nil)
        } else {
            newUser.name = nameTextField.text!
            newUser.username = usernameTextField.text!
            newUser.description = descTextView.text!
            newUser.email = email
            
            
            preferences.set(newUser.username, forKey: "username")
            preferences.set(newUser.name, forKey: "name")
            preferences.set(newUser.email, forKey: "email")
            preferences.set(newUser.description, forKey: "description")
        }
        
        if (segue.identifier == "selectCategorySegue"){
            let destination = segue.destination as! SelectCategoryViewController
            destination.user = newUser
        }
        preferences.set(items, forKey: "categoryList")
        preferences.synchronize()
    }
}
