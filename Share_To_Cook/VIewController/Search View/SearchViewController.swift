//
//  SearchViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 29/4/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DatabaseListener {
    
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var searchRecipeBar: UISearchBar!
    @IBOutlet weak var searchSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchResultLabel: UILabel!
    
    var recipeList = [Recipe]()
    var searchResult = [Recipe]()
    weak var databaseController: DatabaseProtocol?
    var searchBy = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchRecipeBar.delegate = self
        searchRecipeBar.enablesReturnKeyAutomatically = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        self.searchResultTableView.rowHeight = 150.0
        
        searchResultLabel.text = ""
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType =  ListenerType.recipe
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {
        recipeList = recipes
    }
    
    func onCommentListChange(change: DatabaseChange, comments: [Comment]) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResult.count > 0 {
            let searchResultCell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! SearchResultTableViewCell
            
            searchResultCell.titleLabel.text = searchResult[indexPath.row].title
            
            searchResultCell.prepTimeLabel.text = "Total cooking time: " +  String(searchResult[indexPath.row].prepTime + searchResult[indexPath.row].cookTime)
            searchResultCell.ingredientCountLabel.text = "Total ingredients: " +  String(searchResult[indexPath.row].ingredients.count)
            
            searchResultCell.imageView?.image = searchResult[indexPath.row].image
            searchResultCell.createdByLabel.text = searchResult[indexPath.row].creator
            return searchResultCell
        }
        return UITableViewCell()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 0 means search by name
        if searchBy == 0 {
            if let searchParam = searchRecipeBar.text?.lowercased(), searchParam.count > 0 {
                searchResult = recipeList.filter({ (recipe: Recipe) -> Bool in
                    recipe.title.lowercased().contains(searchParam)
                })
            }
        }
        // 1 means search by category
        else if searchBy == 1 {
            if let searchParam = searchRecipeBar.text?.lowercased(), searchParam.count > 0 {
                searchResult = recipeList.filter({ (recipe: Recipe) -> Bool in
                    recipe.category.lowercased().contains(searchParam)
                })
            }
        }
        self.searchResultLabel.text = "Showing " + String(searchResult.count) + " results"
        searchResultTableView.reloadData()
    }
    
    // This function is used to determine the search method
    @IBAction func searchBySelector(_ sender: Any) {
        switch searchSegmentedControl.selectedSegmentIndex {
        case 0:
            searchBy = 0
        case 1:
            searchBy = 1
        default:
            break
        }
    }

}
