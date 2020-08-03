//
//  InstructionsTableViewCell.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 21/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit

class InstructionsTableViewCell: UITableViewCell {

    @IBOutlet weak var instructionTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
