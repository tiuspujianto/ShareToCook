//
//  Recipe.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 12/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import Foundation
import UIKit

// A recipe class to create recipe object
class Recipe  {
    var id: String
    var title: String
    var prepTime: Int
    var cookTime: Int
    var ingredients: [String]
    var instructions: [String]
    var URLImage: String?
    var image: UIImage?
    var creator: String
    var category: String
    var commentList: [Comment]
    var filePath: String?
    
    init() {
        self.id = ""
        self.creator = ""
        self.title = ""
        self.prepTime = 0
        self.cookTime = 0
        self.ingredients = []
        self.instructions = []
        self.URLImage = ""
        self.category = ""
        self.commentList = []
    }
}
