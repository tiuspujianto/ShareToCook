//
//  SearchResultTableViewCell.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 1/6/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Cosmos

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var ingredientCountLabel: UILabel!
    
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet var searchResultImageView: UIImageView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
