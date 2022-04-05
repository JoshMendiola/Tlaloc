//
//platListViewController.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/19/22.
//

import UIKit
import CoreData


let appDelegate = UIApplication.shared.delegate as? AppDelegate

class plantListViewController: UIViewController
{
    
    //intializes the variables including the segmented controlm, the tableview, and time and date keepers
    var plants: [PlantInformation] = []
    var plantCalendarInfo: [PlantCalendar] = []
    private var tableDecision: Int = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedController: segmentedControllerExt!
    @IBOutlet weak var aboutBtn: UIButton!
    var preferredNotifTime: Date = Date()
    let timeKeeper = UserDefaults.standard
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    var selectedDate = Date()
    var totalSquares = [String]()
    
    //these set up the proper presentation of the view controller and its objects
    override func viewDidLoad()
    {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        segmentedController.defaultConfiguration()
        aboutBtn.layer.cornerRadius = 10.0
        calendarView.isHidden = true
        setCellView()
        setMonthView()
        //formats the dates to set the preferred time for the user to see notifications for when the swipe action is used
        if timeKeeper.object(forKey: "desiredTime") != nil
        {
            preferredNotifTime = (timeKeeper.object(forKey: "desiredTime") as? Date)!
        }
        else
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let someDateTime = formatter.date(from: "00:00:00")
            preferredNotifTime = someDateTime!
        }
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
            //if user wants to see the watering schedule
            case 0:
                tableDecision = 0
                fetchCoreDataObjects()
                tableView.reloadData()
                calendarView.isHidden = true
                break
            //if user wants to see the fertilizer schedule
            case 1:
                tableDecision = 1
                fetchCoreDataObjects()
                tableView.reloadData()
                calendarView.isHidden = true
                break
            //if user wants to see the calender
            case 2:
                tableDecision = 2
                tableView.isHidden = true
                tableView.reloadData()
                calendarView.isHidden = false
                setMonthView()
                setCellView()
                break
            //breakpoint here
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
    //segues into the about section
    @IBAction func aboutBtnWasPressed(_ sender: Any)
    {
        guard let plantAboutViewController = storyboard?.instantiateViewController(withIdentifier: "plantAboutViewController") else {return}
        presentDetailFromLeft(plantAboutViewController)
    }
    @IBAction func previousMonthBtnWasPressed(_ sender: Any)
    {
        selectedDate = calendarExt().minusMonth(date: selectedDate)
        setMonthView()
    }
    @IBAction func nextMonthBtnWasPressed(_ sender: Any)
    {
        selectedDate = calendarExt().plusMonth(date: selectedDate)
        setMonthView()
    }
    @IBAction func plantsCaredForThatDayBtn(_ sender: Any)
    {
        if(fetchCalenderInfo(dateToCheck: selectedDate))
        {
            
        }
        
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
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
        if(tableDecision == 0)
        {
            let resetAction = UIContextualAction(style: .normal, title: "Water")
            { [self] (rowAction, view, completion: (Bool) -> Void) in
                self.plants[indexPath.row].nextWaterDate = Calendar.current.date(byAdding: .day, value: Int(self.plants[indexPath.row].daysBetweenWater), to: currentDate)!
                completion(true)
                
                //deletes the previously planned notification
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.plants[indexPath.row].plantID! + "Water"])
                
                //plans a new notification with the new nextwater date
                let waterContent = UNMutableNotificationContent()
                waterContent.title = self.plants[indexPath.row].plantName! + " needs water !"
                waterContent.subtitle = "Log in now and water your plant"
                waterContent.sound = UNNotificationSound.default
                let futureWaterNotifDate = self.combineDateWithTime(date: self.plants[indexPath.row].nextWaterDate!, time: self.preferredNotifTime)
                
                //makes the notification request
                let waterTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day,.hour,.minute], from: futureWaterNotifDate!), repeats: true)
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
            { [self] (rowAction, view, completion: (Bool) -> Void) in
                self.plants[indexPath.row].nextFertilizerDate = Calendar.current.date(byAdding: .day, value: Int(self.plants[indexPath.row].daysBetweenFertilizer), to: currentDate)!
                completion(true)
                
                //deletes the previously planned notification
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.plants[indexPath.row].plantID! + "Fertilizer"])
                
                //checks if plant needs fertilizer
                if self.plants[indexPath.row].needsFertilizer
                {
                    //schedules next fertilizer notification with the new nextfertilizer date
                    let fertilizerContent = UNMutableNotificationContent()
                    fertilizerContent.title = self.plants[indexPath.row].plantName! + " needs fertilizer !"
                    fertilizerContent.subtitle = "Log in now and fertilize your plant"
                    fertilizerContent.sound = UNNotificationSound.default
                    let futureFertilizerNotifDate = self.combineDateWithTime(date: self.plants[indexPath.row].nextFertilizerDate!, time: self.preferredNotifTime)
                    let fertilizerTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day,.hour,.minute], from: futureFertilizerNotifDate!), repeats: true)
                    
                    //makes the notification request
                    let fertilizerRequest = UNNotificationRequest(identifier: (self.plants[indexPath.row].plantID! + "Fertilizer"), content: fertilizerContent, trigger: fertilizerTrigger)
                    UNUserNotificationCenter.current().add(fertilizerRequest)
                }
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
    
    func fetchCalenderInfo(dateToCheck: Date) -> Bool
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return false}
        
        let fetchRequest = NSFetchRequest<PlantCalendar>(entityName: "PlantCalendar")
    
        let pred = NSPredicate(format: "activeDay LIKE %@", argumentArray: [dateToCheck])
        
        fetchRequest.predicate = pred
        
        do
        {
            plantCalendarInfo = try managedContext.fetch(fetchRequest)
            if (plantCalendarInfo != [])
            {
                return true
            }
            return false
        }
        catch
        {
            debugPrint("Could not fetch :( : \(error.localizedDescription)")
        }
        return false
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
    
    //this handles the calculations of combining both the dates and time, to create one mega date
    func combineDateWithTime(date: Date, time: Date) -> Date?
    {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
    
        return calendar.date(from: mergedComponments)
    }
}

extension plantListViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! calendarCell
        
        cell.dayLabel.text = totalSquares[indexPath.item]
        cell.layer.cornerRadius = 5.0
        if(totalSquares[indexPath.item] == "")
        {
            cell.backgroundColor = UIColor(displayP3Red: 247/256, green: 204/256, blue: 134/256, alpha: 1.0)
            cell.plantWasCaredForThatDayBtn.isHidden = true
        }
        else
        {
            cell.backgroundColor = UIColor(displayP3Red: 235/256, green: 168/256, blue: 69/256, alpha: 1.0)
            cell.plantWasCaredForThatDayBtn.isHidden = false
            cell.plantWasCaredForThatDayBtn.layer.cornerRadius = 15.0
        }
        
        return cell
    }
    
    func setCellView()
    {
        let width = (calendarCollectionView.frame.size.width - 2) / 8
        let height = (calendarCollectionView.frame.size.height - 2) / 8
        
        let flowLayout = calendarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonthView()
    {
        totalSquares.removeAll()
        
        let daysInMonth = calendarExt().daysInMonth(date: selectedDate)
        let firstDayOfMonth = calendarExt().firstOfMonth(date: selectedDate)
        let startingSpaces = calendarExt().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while(count <= 42)
        {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth)
            {
                totalSquares.append("")
            }
            else
            {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        
        monthLabel.text = calendarExt().monthString(date: selectedDate) + " " + calendarExt().yearString(date: selectedDate)
        calendarCollectionView.reloadData()
    }
    
}
