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
    //intializes the variables including the segmented control, the tableview, and time and date keepers
    var plants: [PlantInformation] = []
    var plantCalendarInfo: [PlantCalendar] = []
    var plantActivityInfo: [PlantCalendar] = []
    private var tableDecision: Int = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plantActivityTableView: UITableView!
    @IBOutlet weak var segmentedController: segmentedControllerExt!
    @IBOutlet weak var aboutBtn: UIButton!
    var preferredNotifTime: Date = Date()
    let timeKeeper = UserDefaults.standard
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var closedPlantActivityBtn: UIButton!
    var selectedDate = Date()
    var totalSquares = [String]()
    var plantNameHolder: String = "placeholder"
    @IBOutlet weak var plantInstructionsView: UIView!
    var plantWasWatered: Bool = true
    @IBOutlet weak var plantsCaredForListView: UIView!
    @IBOutlet weak var plantsCaredForDateView: UIView!
    @IBOutlet weak var plantActivityDayLabel: UILabel!
    @IBOutlet weak var plantActivityMonthLabel: UILabel!
    @IBOutlet weak var plantActivityYearLabel: UILabel!
    @IBOutlet weak var plantinstructionsViewHeader: UIView!
    @IBOutlet weak var plantInstructionsViewExitBtn: UIButton!
    
    //these set up the proper presentation of the view controller and its objects
    override func viewDidLoad()
    {
        tableView.delegate = self
        tableView.dataSource = self
        plantActivityTableView.delegate = self
        plantActivityTableView.dataSource = self
        tableView.isHidden = false
        segmentedController.defaultConfiguration()
        aboutBtn.layer.cornerRadius = 10.0
        plantsCaredForDateView.layer.cornerRadius = 15.0
        plantsCaredForListView.layer.cornerRadius = 15.0
        plantActivityTableView.layer.cornerRadius = 15.0
        plantInstructionsViewExitBtn.layer.cornerRadius = 15.0
        plantinstructionsViewHeader.layer.cornerRadius = 15.0
        plantInstructionsView.layer.cornerRadius = 15.0
        plantsCaredForListView.isHidden = true
        calendarView.isHidden = true
        closedPlantActivityBtn.layer.cornerRadius = 15.0
        fetchCoreDataObjects()
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
        
        if(isAppAlreadyLaunchedOnce())
        {
            plantInstructionsView.isHidden = true
        }
        else
        {
            plantInstructionsView.isHidden = false
        }
        
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
        tableView.reloadData()
        plantActivityTableView.reloadData()
        calendarCollectionView.reloadData()
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
                plantsCaredForListView.isHidden = true
                break
            //if user wants to see the fertilizer schedule
            case 1:
                tableDecision = 1
                fetchCoreDataObjects()
                tableView.reloadData()
                calendarView.isHidden = true
                plantsCaredForListView.isHidden = true
                break
            //if user wants to see the calender
            case 2:
                tableDecision = 2
                fetchCoreDataObjects()
                tableView.isHidden = true
                calendarView.isHidden = false
                setMonthView()
                setCellView()
                calendarCollectionView.reloadData()
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
    
    //handles in the case the user wants to switch the calendar to the previous monht
    @IBAction func previousMonthBtnWasPressed(_ sender: Any)
    {
        selectedDate = calendarExt().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func exitPlantInstructionBtnWasPressed(_ sender: Any)
    {
        plantInstructionsView.isHidden = true
    }
    //handles in the case the user wants to switch the calendar to the next month
    @IBAction func nextMonthBtnWasPressed(_ sender: Any)
    {
        selectedDate = calendarExt().plusMonth(date: selectedDate)
        setMonthView()
    }
    @IBAction func closePlantActivityBtnWasPressed(_ sender: Any)
    {
        plantsCaredForListView.isHidden = true
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            print("App already launched")
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
}

//this handles the tables and their processing and presentation
extension plantListViewController: UITableViewDelegate, UITableViewDataSource
{
    //basic tableview information allowing for proper presentation of tableview details
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(tableView == self.tableView)
        {
            return plants.count
        }
        else
        {
            return plantActivityInfo.count
        }
    }
    
    //calls upon the plant cell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(tableView == self.tableView)
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell") as? plantCell
            else {return UITableViewCell()}
            let plant = plants[indexPath.row]
            cell.configureCell(plant: plant, tableChoice: tableDecision)
            return cell
        }
        else
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell") as? activityCell
            else {return UITableViewCell()}
            let plantActivity = plantActivityInfo[indexPath.row]
            cell.configureCell(plantActivity: plantActivity)
            return cell
        }
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
        if(tableView == self.tableView)
        {
            //grabs the current date
            let date = Date()
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
            let currentDate = Calendar.current.date(from: dateComponents)!
            selectedDate = currentDate
            plantNameHolder = self.plants[indexPath.row].plantName!
            
            //true equaling the water choice, this calculates the amount of days until the upcoming water date and resets the day counter to the distance to the upcoming date
            if(tableDecision == 0)
            {
                plantWasWatered = true
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
                plantWasWatered = false
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
        return UISwipeActionsConfiguration()
    }
    
    //this handles the transition to the editing screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(tableView == self.tableView)
        {
            guard let plantEditViewController = storyboard?.instantiateViewController(withIdentifier: "plantEditViewController") as? plantEditViewController else {return}
            plantEditViewController.initdata(dex: indexPath.row)
            presentDetail(plantEditViewController)
        }
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
        let calendarFetchRequest = NSFetchRequest<PlantCalendar>(entityName: "PlantCalendar")
        
        do
        {
            plants = try managedContext.fetch(fetchRequest)
            plantCalendarInfo = try managedContext.fetch(calendarFetchRequest)
            completion(true)
        }
        catch
        {
            debugPrint("Could not fetch :( : \(error.localizedDescription)")
            completion(false)
        }
    }
    
    //checks to see if there are any references to this date in the system at all
    func fetchCalenderInfo(dateToCheck: Date) -> Bool
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return false}
        
        let fetchRequest = NSFetchRequest<PlantCalendar>(entityName: "PlantCalendar")
        
        let pred = NSPredicate(format: "activeDay == %@", argumentArray: [dateToCheck])
        
        
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
    
    //grabs all of the instances of plant activity on the specific date passed to it
    func fetchPlantActivityInfo(dateToCheck: Date) -> [PlantCalendar]
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return []}
        
        let fetchRequest = NSFetchRequest<PlantCalendar>(entityName: "PlantCalendar")
        
        let pred = NSPredicate(format: "activeDay == %@", argumentArray: [dateToCheck])
        
        
        fetchRequest.predicate = pred
        
        do
        {
            plantCalendarInfo = try managedContext.fetch(fetchRequest)
            return plantCalendarInfo
        }
        catch
        {
            debugPrint("Could not fetch :( : \(error.localizedDescription)")
        }
        return []
    }
    
    func save(completion: (_ finished: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else { return }
        
        let plantCalandarList = PlantCalendar(context: managedContext)
        
        let saveDate = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: selectedDate)
        let alreadyInCoreData = checkRecordExists(saveDate!, plantName: plantNameHolder, wasWatered: plantWasWatered)
        
        if(alreadyInCoreData)
        {
            completion(false)
            debugPrint("FOUND IT IN CORE DATA: NOT SAVING")
            return
        }
        plantCalandarList.activeDay = saveDate
        debugPrint("THIS IS THE DATE GETTING SAVED")
        debugPrint(saveDate!)
        plantCalandarList.plantCaredFor = plantNameHolder
        plantCalandarList.wasWatered = plantWasWatered
        
        debugPrint(selectedDate)
        debugPrint(plantNameHolder)
        debugPrint(plantWasWatered)
        
        do
        {
            try managedContext.save()
            debugPrint("plantCalendar info was saved!")
            completion(true)
        }
        catch
        {
            debugPrint("Could not save !: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func checkRecordExists(_ dateToCheck: Date, plantName: String, wasWatered: Bool) -> Bool {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else { return false}
        
        
        let fetchRequest = NSFetchRequest<PlantCalendar>(entityName: "PlantCalendar")
        
        debugPrint(dateToCheck)
        debugPrint(plantName)
        debugPrint(wasWatered)
        
        let pred = NSPredicate(format: "activeDay == %@ && plantCaredFor == %@ && wasWatered == %@", argumentArray: [dateToCheck,plantName, wasWatered])
        
        fetchRequest.predicate = pred
        var results: [PlantCalendar] = []
        
        do
        {
            results = try managedContext.fetch(fetchRequest)
            debugPrint("The results:", results.count)
        }
        catch
        {
            print("error executing fetch request: \(error)")
        }

        return results.count > 0

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
    
    //determines size of the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        totalSquares.count
    }
    
    //this determines the interior setup for each cell as it is loaded
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! calendarCell
        cell.dayLabel.text = totalSquares[indexPath.item]
        if(totalSquares[indexPath.item] != "")
        {
            //grabs desired month value
            let monthValue = Calendar.current.dateComponents([.month], from: selectedDate).month
            
            //grabs desired year value
            let yearValue = Calendar.current.dateComponents([.year], from: selectedDate).year
            
            let newDate = combineDateWithDay(Int(totalSquares[indexPath.item])!,monthValue: monthValue!, yearValue: yearValue!)
            cell.configureCell(selectedDate: newDate, wasAnActiveDay: fetchCalenderInfo(dateToCheck: newDate))
        }
        else
        {
            cell.configureNonDateCell()
        }
        cell.layer.cornerRadius = 5.0
        cell.delegate = self
        return cell
    }
    
    //this determines how the cells interact with eachother
    func setCellView()
    {
        let width = (calendarCollectionView.frame.size.width - 2) / 8
        let height = (calendarCollectionView.frame.size.height - 2) / 8
        
        let flowLayout = calendarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    //this sets up the calendar in the correct orientation for the whole month
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
    
    //this combines a specifc day and a specific date to pass to the cell itself
    func combineDateWithDay(_ dayValue: Int, monthValue: Int, yearValue: Int) -> Date
    {
        var components = DateComponents()
        components.day = dayValue
        components.month = monthValue
        components.year = yearValue
        components.hour = 0
        components.minute = 0
        components.second = 0
        let newDate = Calendar.current.date(from: components)
        
        return newDate!
    }
}

extension plantListViewController: calendarCellDelegate
{
    func plantActivityBtnWasPressed(dateToShow: Date)
    {
        plantActivityInfo = fetchPlantActivityInfo(dateToCheck: dateToShow)
        self.plantActivityTableView.reloadData()
        plantsCaredForListView.isHidden = false
        plantActivityDayLabel.text = String(calendarExt().dayString(date: dateToShow))
        plantActivityMonthLabel.text = calendarExt().monthString(date: dateToShow)
        plantActivityYearLabel.text = calendarExt().yearString(date: dateToShow)
    }
}
