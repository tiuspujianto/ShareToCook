//
//  SavedRecipeTableViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 27/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit

class SavedRecipeTableViewController: UITableViewController {
    
    var savedRecipeTitle = [String]()
    var savedFileName = [String]()
    let preference = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if preference.array(forKey: "savedRecipeTitle") != nil {
            savedRecipeTitle = preference.array(forKey: "savedRecipeTitle") as! [String]
            savedFileName = preference.array(forKey: "savedFileName") as! [String]
        }
   
        print (savedFileName)
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRecipeTitle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedRecipeCell", for: indexPath) as! SavedRecipeCellTableViewCell
        cell.recipeTitleLabel.text = savedRecipeTitle[indexPath.row]
        return cell
    }
    
    // Passing the selected recipe to show in pdf
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showPdfSegue") {
            let index = self.tableView.indexPathForSelectedRow
            let destination = segue.destination as! ShowPDFViewController
            destination.fileName = savedFileName[(index?.row)!]
        }
    }
}
