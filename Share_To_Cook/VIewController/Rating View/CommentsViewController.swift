//
//  CommentsViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 25/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    
    var recipe: Recipe?
    
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    let database = Firestore.firestore()
    
    var commentList = [Comment]()
    var filteredComment = [Comment]()
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeTitleLabel.text = recipe?.title
        imageView.image = recipe?.image
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.rowHeight = 115
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let preference = UserDefaults.standard
        preference.set(self.recipe?.id, forKey: "recipeID")
        preference.synchronize()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for comment in commentList{
            if comment.recipe == recipe?.id {
                if !(filteredComment.contains(where: { (comment) -> Bool in
                    true
                })){
                    filteredComment.append(comment)
                }
                
            }
        }
        
        return filteredComment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create the cell for tableview
        let commentsCell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableViewCell
        commentsCell.usernameLabel.text = filteredComment[indexPath.row].commentBy
        commentsCell.commentLabel.text = filteredComment[indexPath.row].comments
        return commentsCell
    }
    // Setting up the listener
    var listenerType = ListenerType.comment
    
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe]) {
    }
    
    func onCommentListChange(change: DatabaseChange, comments: [Comment]) {
        commentList = comments
        commentsTableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCommentDetailSegue") {
            let index = self.commentsTableView.indexPathForSelectedRow
            let destination = segue.destination as! ShowCommentDetailViewController
            destination.comment = filteredComment[(index?.row)!]
            
        }
    }
    

}
