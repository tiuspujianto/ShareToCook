//
//  User.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 5/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import Foundation

// A user class to create user object
class User  {
    var id: String
    var name: String
    var email: String
    var username: String
    var favouriteCategory: [String]
    var description: String
    
    init() {
        self.id = ""
        self.name = ""
        self.email = ""
        self.username = ""
        self.favouriteCategory = []
        self.description = ""
    }
}
