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
    var dex: Int = 0
    @IBOutlet weak var plantNameEditor: UITextView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
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
    func fetchCoreDataObjects()
    {
        self.fetch { (complete) in
            if complete {
               return
            }
        }
    }
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetail()
    }
    @IBAction func updateBtnWasPressed(_ sender: Any)
    {
        plants[dex].plantName = plantNameEditor.text
        self.save { (complete) in
            if complete
            {
                dismiss(animated: true, completion: nil)
            }
        }
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
}
