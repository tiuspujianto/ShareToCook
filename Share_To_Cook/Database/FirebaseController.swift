//
//  Firebasecontroller.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 8/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//


import Firebase

// The firebase database controller

class FirebaseController: NSObject, DatabaseProtocol {
    //
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var userRef: CollectionReference?
    var recipeRef: CollectionReference?
    var categoryRef: CollectionReference?
    var commentRef: CollectionReference?
    
    var user: User
    var recipeList = [Recipe]()
    var commentList =  [Comment]()
    //
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        user = User()
        super.init()
        self.setUpListener()
    }
    
    //Creating the listener
    func setUpListener(){
        recipeRef = database.collection("recipe")
        recipeRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseSnapshotRecipe(snapshot: querySnapshot!)
        }
        
        userRef = database.collection("user")
        userRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print ("Error fetching documents: \(error!)")
                return
            }
            self.parseSnapshotUser(snapshot: querySnapshot!)
        }
        
        commentRef = database.collection("comment")
        commentRef?.addSnapshotListener { (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print ("Error fetching documents: \(error!)")
                return
            }
            self.parseSnapshotComment(snapshot: querySnapshot!)
        }
    }
    
    
    func parseSnapshotUser(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach {change in
            let documentRef = change.document.documentID
            let name = change.document.data()["name"] as! String
            let description = change.document.data()["description"] as! String
            let email = change.document.data()["email"] as! String
            let favourite = change.document.data()["favourite"] as! [String]
            let username = change.document.data()["username"] as! String
            
            if change.type == .added {
                let newUser = User()
                newUser.name = name
                newUser.description = description
                newUser.email = email
                newUser.username = username
                newUser.favouriteCategory = favourite
                newUser.id = documentRef
            }
        }
    }
    
    func parseSnapshotRecipe(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { change in
            
            let documentRef = change.document.documentID
            let title = change.document.data()["title"] as! String
            let category = change.document.data()["category"] as! String
            let prepTime = change.document.data()["prep_time"] as! Int
            let cookTime = change.document.data()["cook_time"] as! Int
            let ingredients = change.document.data()["ingredients"] as! [String]
            let instructions = change.document.data()["steps"] as! [String]
            let url = change.document.data()["imageRef"] as! String
            let createdBy = change.document.data()["created_by"] as! DocumentReference
            
            // Create new recipe file
            if change.type == .added {
                let newRecipe = Recipe()
                newRecipe.title = title
                newRecipe.category = category
                newRecipe.prepTime = prepTime
                newRecipe.cookTime = cookTime
                newRecipe.instructions = instructions
                newRecipe.ingredients = ingredients
                newRecipe.id = documentRef
                newRecipe.URLImage = url
                createdBy.getDocument {(document, error) in
                    if let document = document {
                        newRecipe.creator = document.data()!["username"] as! String
                    }
                }
                recipeList.append(newRecipe)
            }
            // Modify the recipe
            if change.type == .modified{
                let index = getRecipeIndexByID(reference: documentRef)!
                recipeList[index].title = title
                recipeList[index].category = category
                recipeList[index].prepTime = prepTime
                recipeList[index].cookTime = cookTime
                recipeList[index].instructions = instructions
                recipeList[index].ingredients = ingredients
                recipeList[index].id = documentRef
                recipeList[index].URLImage = url
                createdBy.getDocument {(document, error) in
                    if let document = document {
                        self.recipeList[index].creator = document.data()!["username"] as! String
                    }
                }
                recipeList[index].commentList = self.commentList
            }
            if change.type == .removed {
                if let index = getRecipeIndexByID(reference: documentRef){
                    recipeList.remove(at: index)
                }
            }
        }
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.recipe || listener.listenerType == ListenerType.all {
                listener.onRecipeListChange(change: .update, recipes: recipeList)
            }
        }
    }
    
    func parseSnapshotComment(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let documentRef = change.document.documentID
            let userRef = change.document.data()["userID"] as! DocumentReference

            let time = change.document.data()["time"] as! Int
            let difficulties = change.document.data()["difficulties"] as! Int
            let taste = change.document.data()["taste"] as! Int
            let comment = change.document.data()["comments"] as! String
            let recipeRef = change.document.data()["recipe"] as! DocumentReference
            
            if change.type == .added{
                let newComment = Comment()
                newComment.id = documentRef
                newComment.comments = comment
                newComment.difficulties = difficulties
                newComment.taste = taste
                newComment.time = time
                
                userRef.getDocument(completion: { (document, eror) in
                    if let document = document {
                        newComment.commentBy = document.data()!["username"] as! String
                    }
                })
                
                recipeRef.getDocument(completion: { (document, error) in
                    if let document = document {
                        newComment.recipe = document.documentID
                    }
                })
                
                self.commentList.append(newComment)
            }
            if change.type == .modified {
                let index = getCommentById(reference: documentRef)
                commentList[index!].comments = comment
                commentList[index!].difficulties  = difficulties
                commentList[index!].time  = time
                commentList[index!].taste  = taste
                
                userRef.getDocument(completion: { (document, eror) in
                    if let document = document {
                        self.commentList[index!].commentBy = document.data()!["username"] as! String
                    }
                })
                
                recipeRef.getDocument(completion: { (document, error) in
                    if let document = document {
                        self.commentList[index!].recipe = document.documentID
                    }
                })
            }
        }
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.comment || listener.listenerType == ListenerType.all {
                listener.onCommentListChange(change: .update, comments: commentList)
            }
        }

    }
    
    // Function to get a recipe index by its id
    func getRecipeIndexByID(reference: String) -> Int? {
        for recipe in recipeList {
            if(recipe.id == reference) {
                return recipeList.firstIndex(where: { (recipe) -> Bool in
                    true
                })
            }
        }
        
        return nil
    }
    // Function to get a comment by id
    func getCommentById(reference: String) -> Int? {
        for comment in commentList {
            if (comment.id == reference) {
                return commentList.firstIndex(where: { (comment) -> Bool in
                    true
                })
            }
        }
        return nil
    }
    // Function to get a recipe by id
    func getRecipeByID(reference: String) -> Recipe? {
        for recipe in recipeList{
            if (recipe.id == reference) {
                return recipe
            }
        }
        return nil
    }
    // func to add new user
    func addUsers(name: String, username: String, email: String, description: String, favourite: [String]) -> User {
        let newUser = User()
        let id = userRef?.addDocument(data: ["name" : name, "email" :email, "username" : username, "description" : description, "favourite": favourite])
        newUser.id = id!.documentID
        newUser.name = name
        newUser.email = email
        newUser.description = description
        newUser.favouriteCategory = favourite
        newUser.username = username
        return newUser
    }
    // func to add new recipe
    func addRecipe(title: String, prepTime: Int, cookTime: Int, ingredients: [String], steps: [String])-> Recipe {
        let newRecipe = Recipe()
        let id = recipeRef?.addDocument(data: ["title":title, "prep_time": prepTime, "cook_time": cookTime, "ingredients":ingredients, "steps": steps])
        newRecipe.title = title
        newRecipe.prepTime = prepTime
        newRecipe.cookTime = cookTime
        newRecipe.instructions = steps
        newRecipe.ingredients = ingredients
        newRecipe.id = id!.documentID

        return newRecipe
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.recipe{
            listener.onRecipeListChange(change: .update, recipes: recipeList)
        }
        if listener.listenerType == ListenerType.comment{
            listener.onCommentListChange(change: .update, comments: commentList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    func findRecipeByID(reference: String ) -> Recipe? {
        for recipe in recipeList{
            if (recipe.id == reference) {
                return recipe
            }
        }
        return nil
    }
}

