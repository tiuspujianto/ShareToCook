//
//  ShowCommentDetailViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 26/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Cosmos
class ShowCommentDetailViewController: UIViewController {

    @IBOutlet weak var tasteRating: CosmosView!
    @IBOutlet weak var difficultiesRating: CosmosView!
    @IBOutlet weak var timeRating: CosmosView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    var comment: Comment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if comment != nil{
            tasteRating.rating = Double((comment?.taste)!)
            difficultiesRating.rating = Double((comment?.difficulties)!)
            timeRating.rating = Double((comment?.time)!)
            commentTextView.text = comment?.comments
        }
    }
    


}
