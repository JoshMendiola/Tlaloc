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
    @IBOutlet weak var plantNameEditor: UITextView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    func initdata(thisPlant: PlantInformation)
    {
        plantName = thisPlant.plantName
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        plantNameEditor.layer.cornerRadius = 5.0
        updateBtn.layer.cornerRadius = 5.0
        deleteBtn.layer.cornerRadius = 5.0
        plantNameEditor.text = plantName
    }
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetail()
    }
    
    
}
extension plantEditViewController
{
    func removePlant(atIndexPath indexPath: IndexPath)
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(plants[indexPath.row])
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
}

