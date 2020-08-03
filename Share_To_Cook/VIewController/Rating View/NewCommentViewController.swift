//
//  NewCommentViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 12/6/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

class NewCommentViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var tasteRate: CosmosView!
    @IBOutlet var difficultiesRate: CosmosView!
    @IBOutlet var timeRate: CosmosView!
    @IBOutlet var commentTextView: UITextView!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var myImageView: UIImageView!
    
    var urlString = ""
    let preference = UserDefaults.standard
    let database = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextView()
        imagePicker.delegate = self
        commentTextView.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func uploadImageHandler(_ sender: Any) {
        
        let alertController = UIAlertController(title:"", message: "Select one option: ", preferredStyle: .actionSheet)
        let photoButton = UIAlertAction(title: "Select from photos", style: .default, handler: { (UIAlertAction) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            
            self.navigationController?.present(self.imagePicker, animated: true, completion: nil)
        })
        let cameraButton = UIAlertAction(title: "Take a picture", style: .default, handler: nil)
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: {(UIAlertAction) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.navigationController?.present(self.imagePicker, animated: true, completion: nil)
        })
        
        alertController.addAction(photoButton)
        alertController.addAction(cameraButton)
        alertController.addAction(cancelButton)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            myImageView.contentMode = .scaleAspectFit
            myImageView.image = pickedImage
            self.uploadButton.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write something here...."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func setTextView(){
        // Setting up the border of the text view
        commentTextView.layer.cornerRadius = 10
        commentTextView.layer.borderWidth = 0.1
        commentTextView.clipsToBounds = true
        
        commentTextView.text = "Write something here...."
        commentTextView.textColor = UIColor.lightGray
    }
    
    @IBAction func postButtonHandler(_ sender: Any) {
        // uploading an image to the database
        guard let image = myImageView.image, let data = image.jpegData(compressionQuality: 1.0) else{
            let displayMessage = DisplayMessage(title: "Error", msg: "Failed to upload image to the server. Please check your internet connection and try again")
            self.present(displayMessage.alertController, animated: true, completion: nil)
            return
        }
        
        let imageName = UUID().uuidString
        let imageRef = Storage.storage().reference().child(imageName)
        imageRef.putData(data, metadata: nil) { (metadata, err) in
            if let err = err {
                let displayMessage = DisplayMessage(title: "Error", msg: err.localizedDescription)
                self.present(displayMessage.alertController, animated: true, completion: nil)
                return
            }
            
            imageRef.downloadURL(completion: { (url, err) in
                if let err = err {
                    let displayMessage = DisplayMessage(title: "Error", msg: "Failed to download image: \(err.localizedDescription)")
                    self.present(displayMessage.alertController, animated: true, completion: nil)
                }
                guard let url = url else {
                    
                    let displayMessage = DisplayMessage(title: "Error", msg: "Failed to find the image url")
                    self.present(displayMessage.alertController, animated: true, completion: nil)
                    return
                }
                self.urlString = url.absoluteString
                
                // add comment object in the database
                let id = self.preference.string(forKey: "userID")
                let idData = self.database.collection("user")
                let idRef = idData.document(id!)
                let recipeID = self.preference.string(forKey: "recipeID")
                let recipeData = self.database.collection("recipe")
                let recipeRef = recipeData.document(recipeID!)
                self.database.collection("comment").addDocument(data: ["comments": self.commentTextView.text,
                                                                  "difficulties": Int(self.difficultiesRate.rating),
                                                                  "imageURL" : self.urlString,
                                                                  "taste" : Int(self.tasteRate.rating),
                                                                  "time" : Int(self.timeRate.rating),
                                                                  "recipe" : recipeRef,
                                                                  "userID" : idRef])
    
            })
        }
    }
}
