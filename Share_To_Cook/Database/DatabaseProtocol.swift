//
//  DatabaseProtocol.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 8/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case recipe
    case users
    case comment
    case all
}
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onRecipeListChange(change: DatabaseChange, recipes: [Recipe])
    func onCommentListChange(change: DatabaseChange, comments: [Comment])

    
}

protocol DatabaseProtocol: AnyObject {
    func addUsers(name: String, username: String, email: String, description: String, favourite: [String] ) -> User
    func addRecipe(title: String, prepTime: Int, cookTime: Int, ingredients: [String], steps: [String]) -> Recipe
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func findRecipeByID (reference: String) -> Recipe?
}
