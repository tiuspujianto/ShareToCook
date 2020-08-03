//
//  NewRecipeViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 16/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import Firebase

class NewRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Variable declarations
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    
    @IBOutlet weak var cookTimeTextField: UITextField!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionTableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var previewButton: UIBarButtonItem!
    
    var ingredientsCount = 3
    var instructionCount = 3
    
    var ingredientsList:[String] = []
    var instructionList: [String] = []
    var imageSelected: UIImage?
    var newRecipe: Recipe = Recipe()
    var selectedCategory = ""
    let preferences = UserDefaults.standard
    var categoryPicker = UIPickerView()
    var categoryList = [String]()
    let imagePicker = UIImagePickerController()
    // end of variable declaration
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        
        instructionTableView.dataSource = self
        instructionTableView.delegate = self
        
        imagePicker.delegate = self
    
        if imageSelected == nil {
            imageView.image = UIImage(named: "image")
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 0.5
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
        }
        
        let database = Firestore.firestore()
        let databaseRef = database.collection("Category")
        databaseRef.getDocuments {(querySnapshot, err) in
            if let err = err {
                print ("Error getting the documents: \(err)")
            }else{
                for document in querySnapshot!.documents {
                    self.categoryList.append(document.data()["name"] as! String)
                }
                self.selectedCategory = self.categoryList[0]
            }
        }
        
        let toolbar = self.createToolbar()
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        self.categoryPicker.reloadAllComponents()
        self.categoryTextField.inputAccessoryView = toolbar
        self.categoryTextField.inputView = self.categoryPicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector (self.imageTapped(gesture:)))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        categoryTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func createToolbar() -> UIToolbar{
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        return toolbar
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of row in UIPickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categoryList.count
//        return (preferences.stringArray(forKey: "categoryList")?.count)!
    }
    
    // Set up the picker view item
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.categoryList[row]
//        return preferences.stringArray(forKey: "categoryList")![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = self.categoryList[row]
//        selectedCategory = preferences.stringArray(forKey: "categoryList")![row]
    }
    @objc func donePicker(){
        categoryTextField.text = selectedCategory
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientsTableView{
            return ingredientsCount
        }else if tableView == instructionTableView{
            return instructionCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ingredientsTableView{
            let ingredientsCell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell", for: indexPath) as? IngredientsTableViewCell
            ingredientsCell!.ingredientsTextField.delegate = self
            ingredientsCell!.ingredientsTextField.placeholder = "enter your ingredients"
            ingredientsCell!.ingredientsTextField.tag = 1
            
            return ingredientsCell!
            
        }else if tableView == instructionTableView {
            let instructionCell = tableView.dequeueReusableCell(withIdentifier: "instructionsCell", for: indexPath) as? InstructionsTableViewCell
            instructionCell?.instructionTextField.delegate = self
            instructionCell?.instructionTextField.placeholder = "enter the steps required"
            instructionCell?.instructionTextField.tag = 2
            
            return instructionCell!
        }
        return UITableViewCell()
    }

    @IBAction func addNewFieldIngredients(_ sender: Any) {
        ingredientsCount += 1
        ingredientsTableView.reloadData()
    }
 
    @IBAction func addNewFieldInstruction(_ sender: Any) {
        instructionCount += 1
        instructionTableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let origin: CGPoint = textField.frame.origin
        
        if textField == categoryTextField {
            if !(categoryList.contains(categoryTextField.text!)) {
                categoryTextField.text = ""
            }
        }
        if  textField.tag == 1{
            let point: CGPoint = textField.convert(origin, to: self.ingredientsTableView)
            
            let indexPath = self.ingredientsTableView.indexPathForRow(at: point)

            if ingredientsList.count <= (indexPath?.row)! {
                if textField.text != ""{
                    ingredientsList.append(textField.text!)
                }else {
                    if ingredientsCount > 3 {
                        ingredientsCount -= 1
                        ingredientsTableView.reloadData()
                    }
                }
            }else{
                ingredientsList[(indexPath?.row)!] = textField.text!
            }
            
        }else if textField.tag == 2 {
            let point: CGPoint = textField.convert(origin, to: self.instructionTableView)
            
            let indexPath = self.instructionTableView.indexPathForRow(at: point)
            
            if instructionList.count <= (indexPath?.row)! {
                if textField.text != ""{
                    instructionList.append(textField.text!)
                }else {
                    if instructionCount > 3 {
                        instructionCount -= 1
                        instructionTableView.reloadData()
                    }
                }
                
            }else{
                instructionList[(indexPath?.row)!] = textField.text!
            }
        }

    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        
        let alertController = UIAlertController(title:"", message: "Select one option: ", preferredStyle: .actionSheet)
        let photoButton = UIAlertAction(title: "Select from photos", style: .default, handler: { (UIAlertAction) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            
            self.navigationController?.present(self.imagePicker, animated: true, completion: nil)
        })
        let cameraButton = UIAlertAction(title: "Take a picture", style: .default, handler: nil)
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: {(UIAlertAction) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.navigationController?.present(self.imagePicker, animated: true, completion: nil)
        })

        alertController.addAction(photoButton)
        alertController.addAction(cameraButton)
        alertController.addAction(cancelButton)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func checkAllFields() -> Bool{
        let title = "Found empty fields: \n"
        var message = ""
        if (titleTextField.text == ""){
            message += "• Please fill in the recipe title"
            
        }
        if (prepTimeTextField.text == ""){
            message += "\n• Please fill in the preparation time"
            
        }
        if (cookTimeTextField.text == "" ){
            message += "\n• Please fill in the cooking time"
            
        }
        if (categoryTextField.text == ""){
            message += "\n• Please fill in the category"
            
        }
        if (ingredientsList.count == 0){
            message += "\n• The ingredient list can not be empty"
        }
        if (instructionList.count == 0) {
            message += "\n• The instruction list can not be empty"
        }
        if message == "" {
            return true
        }
        let displayMessage = DisplayMessage(title: title, msg: message)
        self.present(displayMessage.alertController, animated: true, completion: nil)
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if checkAllFields() {
            if (segue.identifier == "previewSegue"){
                let destination = segue.destination as! PreviewViewController
                
                newRecipe.title = titleTextField.text!
                newRecipe.prepTime = Int(prepTimeTextField.text!)!
                newRecipe.cookTime = Int(cookTimeTextField.text!)!
                newRecipe.ingredients = ingredientsList
                newRecipe.instructions = instructionList
                newRecipe.image = imageView.image
                newRecipe.category = self.categoryTextField.text!
                
                destination.recipe = newRecipe
                destination.VIEW_MODE = "preview"
            }
        }

    }
    

}
