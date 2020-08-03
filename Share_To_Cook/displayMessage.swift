//
//  DisplayMessage.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 14/6/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Foundation

class DisplayMessage {
    
    var title: String
    var message: String
    var alertController: UIAlertController
    
    init(title: String, msg: String) {
        self.title = title
        self.message = msg
        
        self.alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        self.alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
    }
}
