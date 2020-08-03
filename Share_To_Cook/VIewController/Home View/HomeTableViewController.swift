//
//  HomeTableViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 29/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewController: UITableViewController , DatabaseListener {

    
    
    var recipeList: [Recipe] = []
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarItem()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    //Setting up the tab bar name and icon
    func setTabBarItem(){
        self.tabBarController?.tabBar.items?[0].title = "Home"
        self.tabBarController?.tabBar.items?[0].image = UIImage(named: "home")
        
        self.tabBarController?.tabBar.items?[1].title = "Search"
        self.tabBarController?.tabBar.items?[1].image = UIImage(named: "search")
        
        self.tabBarController?.tabBar.items?[2].title = "Profile"
        self.tabBarController?.tabBar.items?[2].image = UIImage(named: "profile")
        
        self.tabBarController?.tabBar.items?[3].title = "Saved"
        self.tabBarController?.tabBar.items?[3].image = UIImage(named: "saved")
        
        self.tabBarController?.tabBar.items?[4].title = "Setting"
        self.tabBarController?.tabBar.items?[4].image = UIImage(named: "setting")
    }
    

    // MARK: - Table view data source
    var listenerType = ListenerType.recipe

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recipeList.count
    }

    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {
        recipeList = recipes
        tableView.reloadData()
    }
    
    func onCommentListChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipeCell = tableView.dequeueReusableCell(withIdentifier: "recipe_cell", for: indexPath) as! RecipeViewCell
        let recipe = recipeList[indexPath.row]
        let url = recipe.URLImage
        
        if let image = recipe.image {
            recipeCell.imageView?.image = image
        }
        else {
            let imageRef = Storage.storage().reference(forURL: url!)
            imageRef.getData(maxSize: 1 * 1024 * 1024) { data,error in
                if let error = error {
                    print ("There is an error when downloading imges: \(error)")
                }
                let recipeImage = UIImage(data: data!)
                recipe.image = self.scaleUIImageToSize(image: recipeImage!, size: CGSize.init(width: 70, height: 70))
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        recipeCell.titleLabel.text = recipe.title
        
        recipeCell.prepTimeLabel.text = "Total cooking time: " + String(recipe.prepTime + recipe.cookTime)
        recipeCell.ingredientsCountLabel.text = "Total ingredients: " + String(recipe.ingredients.count)
        
        recipeCell.createdByLabel.text = recipe.creator
        return recipeCell
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false since you do not want the item to be edited.
        return false
    }
    
    func scaleUIImageToSize(image: UIImage, size: CGSize) -> UIImage{
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "newRecipeSegue") {
            let destination = segue.destination as! NewRecipeViewController
            let database = Firestore.firestore()
            let databaseRef = database.collection("Category")
            databaseRef.getDocuments {(querySnapshot, err) in
                if let err = err {
                    print ("Error getting the documents: \(err)")
                }else{
                    for document in querySnapshot!.documents {
                        destination.categoryList.append(document.data()["name"] as! String)
                    }
                }
            }
        }else if (segue.identifier == "recipeDetailSegue"){
            let index = self.tableView.indexPathForSelectedRow
            let destination = segue.destination as! PreviewViewController
            destination.recipe = recipeList[(index?.row)!]
            destination.VIEW_MODE = "recipeDetail"
        }
    }
    
    
    

}
