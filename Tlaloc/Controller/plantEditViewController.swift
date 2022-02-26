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
    @IBOutlet weak var waterDayCount: UITextField!
    @IBOutlet weak var fertilizerDayCount: UITextField!
    
    //initalizers and viewcontroller presentation
    func initdata(dex: Int)
    {
        self.dex = dex
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard()
        fetchCoreDataObjects()
        plantNameEditor.layer.cornerRadius = 5.0
        updateBtn.layer.cornerRadius = 5.0
        deleteBtn.layer.cornerRadius = 5.0
        waterDayCount.layer.cornerRadius = 5.0
        fertilizerDayCount.layer.cornerRadius = 5.0
        plantNameEditor.text = plants[dex].plantName
        waterDayCount.text = String(plants[dex].daysBetweenWater)
        fertilizerDayCount.text = String(plants[dex].daysBetweenFertilizer)
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
        //cancels any pending notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plants[dex].plantID! + "Water"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plants[dex].plantID! + "Fertilizer"])
        
        //resets the core data to the inputted values
        plants[dex].plantName = plantNameEditor.text
        plants[dex].daysBetweenWater = Int16(waterDayCount.text!)!
        plants[dex].daysBetweenFertilizer = Int16(fertilizerDayCount.text!)!
        (plants[dex].nextWaterDate,plants[dex].nextFertilizerDate) = calculateNextDate(waterDayCount: plants[dex].daysBetweenWater, fertilizerDayCount: plants[dex].daysBetweenFertilizer)
        
        let waterContent = UNMutableNotificationContent()
        waterContent.title = plants[dex].plantName! + " needs water !"
        waterContent.subtitle = "Log in now and water your plant"
        waterContent.sound = UNNotificationSound.default
        let waterTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day], from: plants[dex].nextWaterDate!), repeats: true)
        
        //handles the future fertilizer notification doing the same thing
        let fertilizerContent = UNMutableNotificationContent()
        fertilizerContent.title = plants[dex].plantName! + " needs fertilizer !"
        fertilizerContent.subtitle = "Log in now and fertilize your plant"
        fertilizerContent.sound = UNNotificationSound.default
        let fertilizerTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day], from: plants[dex].nextWaterDate!), repeats: true)

        //makes both request
        let waterRequest = UNNotificationRequest(identifier: (plants[dex].plantID! + "Water") , content: waterContent, trigger: waterTrigger)
        let fertilizerRequest = UNNotificationRequest(identifier: (plants[dex].plantID! + "Fertilizer"), content: fertilizerContent, trigger: fertilizerTrigger)
        UNUserNotificationCenter.current().add(waterRequest)
        UNUserNotificationCenter.current().add(fertilizerRequest)
        
        //finally, saves the data
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
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plants[dex].plantID! + "Water"])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plants[dex].plantID! + "Fertilizer"])
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
    
    func calculateNextDate(waterDayCount: Int16, fertilizerDayCount: Int16) -> (Date?, Date?)
    {
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let currentDate = Calendar.current.date(from: dateComponents)
        let futureWaterDate = Calendar.current.date(byAdding: .day, value: Int(waterDayCount), to: date)!
        let futureFertilizerDate = Calendar.current.date(byAdding: .day, value: Int(fertilizerDayCount), to: date)!
        
        debugPrint(currentDate!)
        debugPrint(futureFertilizerDate, futureWaterDate)
        
        return (futureFertilizerDate, futureWaterDate)
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
        waterDayCount.inputAccessoryView = doneToolbar
        fertilizerDayCount.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction()
    {
        plantNameEditor.resignFirstResponder()
        waterDayCount.resignFirstResponder()
        fertilizerDayCount.resignFirstResponder()
    }
}
