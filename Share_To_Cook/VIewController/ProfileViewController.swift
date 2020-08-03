//
//  ProfileViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 23/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {

    @IBOutlet var myRecipeTableView: UITableView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var profileNavigationItem: UINavigationItem!
    
    var recipeList = [Recipe]()
    var filteredRecipeList = [Recipe]()
    weak var databaseController: DatabaseProtocol?
    var userName = ""
    var preference = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        userName = preference.string(forKey: "username")!
        
        self.profileNavigationItem.title = userName
        self.nameLabel.text = preference.string(forKey: "name")
        self.descLabel.text = preference.string(forKey: "description")
        myRecipeTableView.delegate = self
        myRecipeTableView.dataSource = self
        self.myRecipeTableView.rowHeight = 150.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        databaseController?.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        databaseController?.removeListener(listener: self)
    }
    var listenerType = ListenerType.recipe
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {
        recipeList = recipes
        filteredRecipeList = recipeList.filter({ (recipe: Recipe) -> Bool in
            recipe.creator.lowercased().elementsEqual(userName.lowercased())
        })
        myRecipeTableView.reloadData()
    }
    
    func onCommentListChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecipeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipeCell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! SearchResultTableViewCell
        recipeCell.createdByLabel.text = filteredRecipeList[indexPath.row].creator
        recipeCell.titleLabel.text = filteredRecipeList[indexPath.row].title
        recipeCell.ingredientCountLabel.text = String(filteredRecipeList[indexPath.row].ingredients.count)
        recipeCell.prepTimeLabel.text = String(filteredRecipeList[indexPath.row].prepTime)
        recipeCell.imageView?.image = filteredRecipeList[indexPath.row].image
        
        return recipeCell
    }
}
