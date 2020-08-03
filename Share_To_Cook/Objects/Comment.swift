//
//  Comment.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 25/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import Foundation
import UIKit

// A comment class to create comment object
class Comment {
    var id: String
    var commentBy: String
    var comments: String
    var difficulties: Int
    var time: Int
    var taste: Int
    var recipe: String
    var image: UIImage?
    var URLImage: String
    
    init() {
        self.id = ""
        self.commentBy = ""
        self.comments = ""
        self.difficulties = 0
        self.time = 0
        self.taste = 0
        self.recipe = ""
        self.URLImage = ""
    }
}
