//
//  ViewController.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/19/22.
//

import UIKit
import CoreData


let appDelegate = UIApplication.shared.delegate as? AppDelegate

class plantListViewController: UIViewController
{
    
    var plants: [PlantInformation] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
        tableView.reloadData()
    }
    
    //fetches core data and checks to see if the table should be visible or not
    func fetchCoreDataObjects()
    {
        self.fetch { (complete) in
            if complete {
                if plants.count >= 1
                {
                    tableView.isHidden = false
                }
                else
                {
                    tableView.isHidden = true
                }
            }
        }
    }
    
    
    @IBAction func addPlantBtnWasPressed(_ sender: Any)
    {
        guard let plantCreationViewController = storyboard?.instantiateViewController(withIdentifier: "plantCreationViewController") else {return}
        presentDetail(plantCreationViewController)
    }
}

//this handles the tables and their processing and presentation
extension plantListViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell") as? plantCell
        else {return UITableViewCell()}
        let plant = plants[indexPath.row]
        cell.configureCell(plant: plant)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        return .none
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "DELETE") { (rowAction, view, completion: (Bool) -> Void) in
            self.removePlant(atIndexPath: indexPath)
            completion(true)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

//This section manages the general fetching, grabbing and managaement of the values within the table
extension plantListViewController
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
