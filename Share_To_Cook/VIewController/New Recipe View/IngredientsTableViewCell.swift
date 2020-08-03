//
//  IngredientsTableViewCell.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 21/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientsTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
