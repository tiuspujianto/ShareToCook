//
//  PreviewViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 22/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import PDFKit

class PreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var recipe: Recipe?
    var VIEW_MODE: String?
    var savedRecipe = [Recipe]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionsTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var ratingView: CosmosView!
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    let database = Firestore.firestore()
    var filePath: String?
    let preference = UserDefaults.standard
    
    var savedFileName: [String]?
    var savedRecipeTitle: [String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        
        instructionsTableView.delegate = self
        instructionsTableView.dataSource = self
        
        loadRecipeData()
        
        if VIEW_MODE == "preview"{
            ratingView.isHidden = true
            
        } else if VIEW_MODE == "recipeDetail"{
            ratingView.isHidden = false
            ratingView.settings.updateOnTouch = false
            postButton.title = "Save"
        }
        
        if preference.array(forKey:"savedRecipeTitle") != nil {
            savedRecipeTitle = preference.array(forKey: "savedRecipeTitle") as? [String]
            savedFileName = preference.array(forKey: "savedFileName") as? [String]
        }else{
            preference.set([String](), forKey: "savedRecipeTitle")
            preference.set([String](), forKey: "savedFileName")
            preference.synchronize()
        }

    }

    
    func loadRecipeData(){
        titleLabel.text = recipe?.title
        prepTimeLabel.text = "Prep: " + String(recipe!.prepTime) + " minutes"
        cookTimeLabel.text = "Cook: " + String(recipe!.cookTime) + " minutes"
        let preferences = UserDefaults.standard
        if VIEW_MODE == "preview" {
            createdByLabel.text = preferences.string(forKey: "username")
        }else {
            createdByLabel.text = recipe?.creator
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = recipe?.image
        
        categoryLabel.text = recipe!.category
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientsTableView{
            return (recipe?.ingredients.count)!
        }else if tableView == instructionsTableView {
            return (recipe?.instructions.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ingredientsTableView{
            let ingredientsCell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell", for: indexPath) as? IngredientsTableViewCell
            ingredientsCell!.ingredientsTextField.text = recipe?.ingredients[indexPath.row]
            ingredientsCell!.ingredientsTextField.tag = 0
            ingredientsCell?.ingredientsTextField.isEnabled = false
            return ingredientsCell!
            
        }else if tableView == instructionsTableView {
            let instructionCell = tableView.dequeueReusableCell(withIdentifier: "instructionsCell", for: indexPath) as? InstructionsTableViewCell
            
            instructionCell?.instructionTextField.text = recipe?.instructions[indexPath.row]
            instructionCell?.instructionTextField.tag = 1
            instructionCell?.instructionTextField.isEnabled = false
            return instructionCell!
        }
        return UITableViewCell()
    }
    
    @objc func uploadPhoto() {
        
        guard let image = imageView.image, let data = image.jpegData(compressionQuality: 1.0) else{
            let displayMessage = DisplayMessage(title: "Error", msg: "Failed to upload image to the server. Please try again")
            self.present(displayMessage.alertController, animated: true, completion: nil)
            return
        }
        
        let imageName = UUID().uuidString
        let imageRef = Storage.storage().reference().child(imageName)
        imageRef.putData(data, metadata: nil) { (metadata, err) in
            if let err = err {
                let displayMessage = DisplayMessage(title: "Error", msg: err.localizedDescription)
                self.present(displayMessage.alertController, animated: true, completion: nil)
                return
            }
            
            imageRef.downloadURL(completion: { (url, err) in
                if let err = err {
                    let displayMessage = DisplayMessage(title: "Error", msg: "Failed to download image: \(err.localizedDescription)")
                    self.present(displayMessage.alertController, animated: true, completion: nil)
                }
                guard let url = url else {
                    let displayMessage = DisplayMessage(title: "Error", msg: "Something went wrong")
                    self.present(displayMessage.alertController, animated: true, completion: nil)
                    return
                }
                let urlString = url.absoluteString
                self.recipe?.URLImage = urlString
                self.uploadData()
            })

        }
    }
    
    @IBAction func postButtonHandler(_ sender: Any) {
        if VIEW_MODE == "preview"{
            self.uploadPhoto()
            
        }else{
            createPDFFile()
        }
    }
    
    func createPDFFile() {
        //
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = "\(recipe!.id).pdf"
        filePath = (documentsDirectory as NSString).appendingPathComponent(fileName) as String
        let pdfTitle = recipe?.title
        let pdfMetadata = [
            kCGPDFContextCreator: "Share_To_Cook",
            kCGPDFContextAuthor: "Timotius Putra Pujianto"
        ]
        print(fileName)
        if !(savedFileName!.contains(fileName)){
            savedFileName!.append(fileName)
        }
        if !(savedRecipeTitle!.contains((recipe?.title)!)){
            savedRecipeTitle!.append((recipe?.title)!)
        }
        
        preference.set(savedFileName, forKey: "savedFileName")
        preference.set(savedRecipeTitle, forKey: "savedRecipeTitle")
        preference.synchronize()
        
        //
        recipe!.filePath = filePath
        
        UIGraphicsBeginPDFContextToFile(filePath!, CGRect.zero, pdfMetadata)
        UIGraphicsBeginPDFPage()
        
        let pageSize = CGSize(width: 595.2, height: 841.8)
        let font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        let attributedPDFTitle = NSAttributedString(string: pdfTitle!, attributes: [NSAttributedString.Key.font: font])
        let stringSize = attributedPDFTitle.size()
        let stringRect = CGRect(x: (pageSize.width / 2 - stringSize.width / 2), y: 20, width: stringSize.width, height: stringSize.height)
        attributedPDFTitle.draw(in: stringRect)
        
        let bodyPDF = NSAttributedString(string: createPDFBodyText(), attributes: [NSAttributedString.Key.font: font])
        let bodyStringSize = bodyPDF.size()
        let stringRectBody = CGRect(x: 50.0, y: 65.0, width: bodyStringSize.width, height: bodyStringSize.height)
        bodyPDF.draw(in: stringRectBody)
        
        UIGraphicsEndPDFContext()
        
        let displayMessage = DisplayMessage(title: "Succesfull", msg: "A pdf file has been created")
        self.present(displayMessage.alertController, animated: true, completion: nil)
    }
    
    func createPDFBodyText() -> String{
        var bodyText = "Created by: \(recipe!.creator)\n\n Prep Time: \(recipe!.prepTime)\n\n Cook Time: \(recipe!.cookTime)\n\n Ingredient: \n\n"
        var i = 1
        for ingredient in (recipe?.ingredients)!{
            bodyText = bodyText + String(i) + ". " + ingredient + "\n"
            i += 1
        }
        var j = 1
        bodyText = bodyText + "\n" + "Steps: \n\n"
        for step in (recipe?.instructions)!{
            bodyText = bodyText + String(j) + ". " + step + "\n"
            j += 1
        }
        return bodyText
    }
    
    func uploadData(){
        let preference = UserDefaults.standard
        let id = preference.string(forKey: "userID")
        let idData = database.collection("user")
        let idRef = idData.document(id!)
        database.collection("recipe").addDocument(data: ["title": recipe?.title,
                                                         "prep_time": recipe?.prepTime,
                                                         "cook_time" : recipe?.cookTime,
                                                         "steps" : recipe?.instructions,
                                                         "ingredients" : recipe?.ingredients,
                                                         "category" : recipe?.category,
                                                         "created_by" : idRef,
                                                         "imageRef" : recipe?.URLImage])
    }
    
    @IBAction func commentButtonHandler(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "commentsViewController") as! CommentsViewController
        newViewController.recipe = recipe
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}
