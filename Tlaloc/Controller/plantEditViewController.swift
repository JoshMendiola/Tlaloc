//
//  plantEditViewController.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 2/1/22.
//

import UIKit
import CoreData

class plantEditViewController: UIViewController
{
    var plantName: String!
    var plants: [PlantInformation] = []
    var dex: Int!
    @IBOutlet weak var plantNameEditor: UITextView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    //initalizers and viewcontroller presentation
    func initdata(dex: Int)
    {
        self.dex = dex
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        fetchCoreDataObjects()
        plantNameEditor.layer.cornerRadius = 5.0
        updateBtn.layer.cornerRadius = 5.0
        deleteBtn.layer.cornerRadius = 5.0
        plantNameEditor.text = plants[dex].plantName
    }
    
    //grabs the data from the core data system
    func fetchCoreDataObjects()
    {
        self.fetch { (complete) in
            if complete {
               return
            }
        }
    }
    
    //back button
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetail()
    }
    
    //updates the plant name with the new name put in the name editor
    @IBAction func updateBtnWasPressed(_ sender: Any)
    {
        plants[dex].plantName = plantNameEditor.text
        self.save { (complete) in
            if complete
            {
                dismissDetail()
            }
        }
    }
    
    //handles deletion of the plant from the core data system
    @IBAction func deleteBtnWasPressed(_ sender: Any)
    {
        dismissDetail()
        removePlant(atIndexPath: [dex])
        debugPrint("Deleted !!!!")
    }
}
extension plantEditViewController
{
    func removePlant(atIndexPath indexPath: IndexPath)
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(plants[dex])
        do
        {
            try managedContext.save()
        }
        catch
        {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
    }
    func fetch(completion: (_ complete: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchRequest = NSFetchRequest<PlantInformation>(entityName: "PlantInformation")
        
        do
        {
            plants = try managedContext.fetch(fetchRequest)
            completion(true)
        }
        catch
        {
            debugPrint("Could not fetch :( : \(error.localizedDescription)")
            completion(false)
        }
    }
    func save(completion: (_ finished: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else { return }
        
        do
        {
            try managedContext.save()
            completion(true)
        }
        catch
        {
            debugPrint("Could not save !: \(error.localizedDescription)")
            completion(false)
        }
    }
    func addDoneButtonOnKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            plantNameEditor.inputAccessoryView = doneToolbar
        }
    @objc func doneButtonAction()
    {
        plantNameEditor.resignFirstResponder()
    }
}
