//
//  SelectCategoryViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 9/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Firebase

class SelectCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
    var database: Firestore!
    var user: User?
    let reuseIdentifier = "my_cell"
    var categoryList: [String] = []
    var selectedCategory: [String] = []
    var preference: UserDefaults = UserDefaults.standard
    

    @IBOutlet weak var collectionCategoryView: UICollectionView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        categoryList = preference.array(forKey: "categoryList") as! [String]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionCategoryView.allowsMultipleSelection = true
        database = Firestore.firestore()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CategoryCollectionViewCell
        cell.myLabel.text = self.categoryList[indexPath.item]
        cell.myLabel.textColor = UIColor.init(displayP3Red: 0, green: 0.478431, blue: 1, alpha: 1.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
        selectedCategory.append(categoryList[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
        let index = selectedCategory.firstIndex(of: "\(categoryList[indexPath.item])")
        selectedCategory.remove(at: index!)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.categoryList.count
    }
    @IBAction func confirmButtonHandler(_ sender: Any) {
        if selectedCategory.count < 3 {
            let displayMessage = DisplayMessage(title: "Selected category is less than 3", msg: "Please select atleast 3 categories")
            self.present(displayMessage.alertController, animated: true, completion: nil)
        }else{
           // Adding new user to the firestore db
            user?.favouriteCategory = selectedCategory
            var ref: DocumentReference? = nil
            ref = database.collection("user").addDocument(data: ["name" : user?.name, "email" : user?.email, "username" : user?.username, "description" : user?.description, "favourite": user?.favouriteCategory]) { err in
                if let err = err {
                    let displayMessage = DisplayMessage(title: "Error", msg: "Error adding document: \(err)")
                    self.present(displayMessage.alertController, animated: true, completion: nil)
                } else {
                    let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "homeMainTabBarController") as UIViewController
                    self.preference.set(ref?.documentID, forKey: "userID")
                    self.preference.set(self.selectedCategory, forKey: "favouriteCategory")
                    self.preference.synchronize()
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
}
