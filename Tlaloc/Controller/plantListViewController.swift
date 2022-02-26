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
    private var tableDecision: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    //these set up the proper presentation of the view controller and its objects
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
    
    //handles the segmented control and setting the correct variables
    @IBAction func tableSwitch(sender : UISegmentedControl)
    {
        //water being chosen represents case 0, fertilizer being chosen represents case 1, with a failsafe for any possible edgecases, returning true for water, and false for fertilizer
        switch sender.selectedSegmentIndex
        {
            case 0:
                tableDecision = true
                tableView.reloadData()
                break
            case 1:
                tableDecision = false
                tableView.reloadData()
                break
            default:
                debugPrint("ERROR: Segmented Control not operating correctly")
                break
        }
    }
    
    //segues into the next view controller
    @IBAction func addPlantBtnWasPressed(_ sender: Any)
    {
        guard let plantCreationViewController = storyboard?.instantiateViewController(withIdentifier: "plantCreationViewController") else {return}
        presentDetail(plantCreationViewController)
    }
}

//this handles the tables and their processing and presentation
extension plantListViewController: UITableViewDelegate, UITableViewDataSource
{
    //basic tableview information allowing for proper presentation of tableview details
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    //calls upon the plant cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell") as? plantCell
        else {return UITableViewCell()}
        let plant = plants[indexPath.row]
        cell.configureCell(plant: plant, tableChoice: tableDecision)
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
    
    //this handles the telling of the core data system that the plant has been succesfully watered
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //grabs the current date
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let currentDate = Calendar.current.date(from: dateComponents)!
        //true equaling the water choice, this calculates the amount of days until the upcoming water date and resets the day counter to the distance to the upcoming date
        if(tableDecision == true)
        {
            let resetAction = UIContextualAction(style: .normal, title: "Water")
            { (rowAction, view, completion: (Bool) -> Void) in
                self.plants[indexPath.row].nextWaterDate = Calendar.current.date(byAdding: .day, value: Int(self.plants[indexPath.row].daysBetweenWater), to: currentDate)!
                completion(true)
                
                //deletes the previously planned notification
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.plants[indexPath.row].plantID! + "Water"])
                
                //plans a new notification with the new nextwater date
                let waterContent = UNMutableNotificationContent()
                waterContent.title = self.plants[indexPath.row].plantName! + " needs water !"
                waterContent.subtitle = "Log in now and water your plant"
                waterContent.sound = UNNotificationSound.default
                let waterTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day], from: self.plants[indexPath.row].nextWaterDate!), repeats: true)
                
                //makes the notification request
                let waterRequest = UNNotificationRequest(identifier: (self.plants[indexPath.row].plantID! + "Water") , content: waterContent, trigger: waterTrigger)
                UNUserNotificationCenter.current().add(waterRequest)
                //reloads the table
                self.fetchCoreDataObjects()
                tableView.reloadData()
            }
            
            resetAction.backgroundColor = UIColor.blue
            //saves the new changes made to the data
            self.save { (complete) in
                if complete
                {
                    return
                }
            }
            return UISwipeActionsConfiguration(actions: [resetAction])
        }
        //does the same in the case that the fertilizer screen is being looked at
        else
        {
            let resetAction = UIContextualAction(style: .normal, title: "Fertilize")
            { (rowAction, view, completion: (Bool) -> Void) in
                self.plants[indexPath.row].nextFertilizerDate = Calendar.current.date(byAdding: .day, value: Int(self.plants[indexPath.row].daysBetweenFertilizer), to: currentDate)!
                completion(true)
                
                //deletes the previously planned notification
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.plants[indexPath.row].plantID! + "Fertilizer"])
                
                //schedules next fertilizer notification with the new nextfertilizer date
                let fertilizerContent = UNMutableNotificationContent()
                fertilizerContent.title = self.plants[indexPath.row].plantName! + " needs fertilizer !"
                fertilizerContent.subtitle = "Log in now and fertilize your plant"
                fertilizerContent.sound = UNNotificationSound.default
                let fertilizerTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day], from: self.plants[indexPath.row].nextWaterDate!), repeats: true)
                
                //makes the notification request
                let fertilizerRequest = UNNotificationRequest(identifier: (self.plants[indexPath.row].plantID! + "Fertilizer"), content: fertilizerContent, trigger: fertilizerTrigger)
                UNUserNotificationCenter.current().add(fertilizerRequest)
                
                //reloads the table
                self.fetchCoreDataObjects()
                tableView.reloadData()
            }
            resetAction.backgroundColor = UIColor.systemBrown
            
            //saves the data
            self.save { (complete) in
                if complete
                {
                    return
                }
            }
            return UISwipeActionsConfiguration(actions: [resetAction])
        }
        
    }
    
    //this handles the transition to the editing screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let plantEditViewController = storyboard?.instantiateViewController(withIdentifier: "plantEditViewController") as? plantEditViewController else {return}
        plantEditViewController.initdata(dex: indexPath.row)
        presentDetail(plantEditViewController)
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
