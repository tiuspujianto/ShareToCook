//
//  RecipeViewCell.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 13/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Cosmos

class RecipeViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet var imageViewCell: UIImageView!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var ingredientsCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingView.settings.updateOnTouch = false
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
