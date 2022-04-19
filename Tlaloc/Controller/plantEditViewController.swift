//
//  plantEditViewController.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 2/1/22.
//

import UIKit
import CoreData
import AVFoundation

class plantEditViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate
{
    var plantName: String!
    var plants: [PlantInformation] = []
    var dex: Int!
    var needsFertilizer: Bool = true
    @IBOutlet weak var plantNameEditor: UITextView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var waterDayCount: UITextField!
    @IBOutlet weak var fertilizerDayCount: UITextField!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantNeedsFertilizerSwitch: UISwitch!
    @IBOutlet weak var changeImgBtn: UIButton!
    var preferredNotifTime: Date = Date()
    let timeKeeper = UserDefaults.standard
    
    //initalizers and viewcontroller presentation
    func initdata(dex: Int)
    {
        //sets the index value to the one passed to the initilalization object
        self.dex = dex
        
        //handles what occurs in the case no notification time was set in the about menu
        if timeKeeper.object(forKey: "desiredTime") != nil
        {
            //saves it to the userdefaults
            preferredNotifTime = (timeKeeper.object(forKey: "desiredTime") as? Date)!
        }
        else
        {
            //defaults the notification time value to midnight
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let someDateTime = formatter.date(from: "00:00:00")
            preferredNotifTime = someDateTime!
        }
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //adds done button the keyboards
        self.addDoneButtonOnKeyboard()
        
        //sets delegates and fetches core data objects
        waterDayCount.delegate = self
        fertilizerDayCount.delegate = self
        plantNameEditor.delegate = self
        fetchCoreDataObjects()
        
        //sets rounded corner to all of the views to fit the UI theme
        plantNameEditor.layer.cornerRadius = 10.0
        updateBtn.layer.cornerRadius = 25.0
        deleteBtn.layer.cornerRadius = 25.0
        waterDayCount.layer.cornerRadius = 10.0
        fertilizerDayCount.layer.cornerRadius = 10.0
        changeImgBtn.layer.cornerRadius = 25.0
        
        //sets text to the values saved in core data for these specific plants
        plantNameEditor.text = plants[dex].plantName
        waterDayCount.text = String(plants[dex].daysBetweenWater)
        fertilizerDayCount.text = String(plants[dex].daysBetweenFertilizer)
        
        var img: UIImage
        
        //checks what image to hold for the plant
        if plants[dex].plantImage == nil
        {
            img = UIImage(named: "pixelplant")!
        }
        else
        {
            img = UIImage(data: plants[dex].plantImage!)!
        }
        
        //checks if plant needs fertilizer
        if plants[dex].needsFertilizer == false
        {
            //determines thta if the plant does NOT need fertilizer, then it should disable the field as a whol
            plantNeedsFertilizerSwitch.isOn = false
            fertilizerDayCount.alpha = 0.5
            fertilizerDayCount.isUserInteractionEnabled = false
            fertilizerDayCount.text = ""
            needsFertilizer = false
        }
        else
        {
            needsFertilizer = true
        }
        
        self.plantImage.image = img
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
    
    //handles what occurs if the user wants to update their plant image
    
    //updates the plant name with the new name put in the name editor
    @IBAction func updateBtnWasPressed(_ sender: Any)
    {
        if inputIsValid()
        {
            //cancels any pending notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plants[dex].plantID! + "Water"])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plants[dex].plantID! + "Fertilizer"])
            
            //resets the core data to the inputted values
            plants[dex].plantName = plantNameEditor.text
            plants[dex].daysBetweenWater = Int16(waterDayCount.text!)!
            plants[dex].needsFertilizer = needsFertilizer
            if plants[dex].needsFertilizer == false
            {
                plants[dex].daysBetweenFertilizer = 500
            }
            else
            {
                plants[dex].daysBetweenFertilizer = Int16(fertilizerDayCount.text!)!
            }
            (plants[dex].nextFertilizerDate, plants[dex].nextWaterDate) = calculateNextDate(waterDayCount: plants[dex].daysBetweenWater, fertilizerDayCount: plants[dex].daysBetweenFertilizer)
            plants[dex].plantImage = plantImage.image?.pngData()
            
            //handles the water notification, setting up for future notifications from this point
            let waterContent = UNMutableNotificationContent()
            waterContent.title = plants[dex].plantName! + " needs water !"
            waterContent.subtitle = "Log in now and water your plant"
            waterContent.sound = UNNotificationSound.default
            let futureWaterNotifTime = combineDateWithTime(date: plants[dex].nextWaterDate!, time: preferredNotifTime)
            let waterTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day,.hour,.minute], from: futureWaterNotifTime!), repeats: true)
            let waterRequest = UNNotificationRequest(identifier: (plants[dex].plantID! + "Water") , content: waterContent, trigger: waterTrigger)
            UNUserNotificationCenter.current().add(waterRequest)
            
            //handles the future fertilizer notification doing the same thing
            if plants[dex].needsFertilizer
            {
                let fertilizerContent = UNMutableNotificationContent()
                fertilizerContent.title = plants[dex].plantName! + " needs fertilizer !"
                fertilizerContent.subtitle = "Log in now and fertilize your plant"
                fertilizerContent.sound = UNNotificationSound.default
                let futureFertilizerNotifTime = combineDateWithTime(date: plants[dex].nextFertilizerDate!, time: preferredNotifTime)
                let fertilizerTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day,.hour,.minute], from: futureFertilizerNotifTime!), repeats: true)
                let fertilizerRequest = UNNotificationRequest(identifier: (plants[dex].plantID! + "Fertilizer"), content: fertilizerContent, trigger: fertilizerTrigger)
                UNUserNotificationCenter.current().add(fertilizerRequest)
            }
            
            //finally, saves the data
            self.save { (complete) in
                if complete
                {
                    dismissDetail()
                }
            }
        }
    }
    
    //handles what occurs when the needs fertilizer btn was switched
    @IBAction func needsFertilizerBtnWasPressed(_ sender: Any)
    {
        if plantNeedsFertilizerSwitch.isOn
        {
            fertilizerDayCount.alpha = 1.0
            fertilizerDayCount.isUserInteractionEnabled = true
            fertilizerDayCount.text = "30"
            needsFertilizer = true
        }
        else
        {
            fertilizerDayCount.alpha = 0.5
            fertilizerDayCount.isUserInteractionEnabled = false
            fertilizerDayCount.text = ""
            needsFertilizer = false
        }
        
        if inputIsValid()
        {
           updateBtn.alpha = 1.0
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
    
    
    //these check to make sure no null inputs are inserted into the system
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if inputIsValid()
        {
            updateBtn.alpha = 1.0
        }
        else
        {
            updateBtn.alpha = 0.5
        }
    }
    
    //changes button alpha to let user know if they can update their plant
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if inputIsValid()
        {
            updateBtn.alpha = 1.0
        }
        else
        {
            updateBtn.alpha = 0.5
        }
    }
    
    //determines if the controller should autorotate, returning false as this view controller (or any of them) should not autorotate given the view is not built to support that
    override open var shouldAutorotate: Bool
    {
        return false
    }
}




extension plantEditViewController
{
    //this removes and deletes a plant from the core data, given the index path of the desired plant to delete
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
    
    //fetches an array of objects from the core data entity PlantInformation, returns true if the fetch is succesful, and returns false in the case that it does not
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
    
    //saves to the core data, returns true is succesful, false if not
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
    
    //takes in two dates, and extracts the date and time values from each, combining the into one megadate to use when setting notification times, usually the time object is taken from the userdefaults which a user would set in the about view controller
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
    
    //calculates two dates, each a certain amount of days ahead of the passed into it, used to calculate when the specific watering and fertilization of each plant should occur
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
    
    //function that adds a done button on the top of the keyboard when displaed, which makes registering when a user is done typing much easier for operations like checking if certain buttons should be accesible to the user yet
    func addDoneButtonOnKeyboard()
    {
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
    
    //an objective C function which gives specific text editing boxes the ability to go away when the user clicks the done button
    @objc func doneButtonAction()
    {
        plantNameEditor.resignFirstResponder()
        waterDayCount.resignFirstResponder()
        fertilizerDayCount.resignFirstResponder()
    }
    
    //checks if all values are validly filled before allowing the update button to be able to be interacted with
    func inputIsValid() -> Bool
    {
        if plantNameEditor.text != "" && waterDayCount.text != "" && Int16(waterDayCount.text!)! > 0
        {
            //if the plant does not need fertilizer, it does not consider how empty the fertilizer field is
            if(needsFertilizer == false)
            {
                return true
            }
            //otherwise, it checks if fertilizer is properly filled in
            else if needsFertilizer == true && fertilizerDayCount.text != "" && Int16(fertilizerDayCount.text!)! > 0
            {
                return true
            }
        }
        updateBtn.alpha = 0.5
        return false
    }
}







//handles the camera and photo library

extension plantEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    //this handles what happens when a user clicks the change image button
    @IBAction func changeImgBtnWasPressed(_ sender: Any)
    {
        checkCameraAccess()
    }
    
    //processes if the user has allowed camera access to the app, if there is no camera access, it provides the user the option to change that otherwise, it runs as normal
    func checkCameraAccess()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video)
        {
            case .denied:
                print("Denied, request permission from settings")
                presentCameraSettings()
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                print("Authorized, proceed")
                accessAllowed()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success
                    {
                        print("Permission granted, proceed")
                        self.accessAllowed()
                    }
                    else
                    {
                        print("Permission denied")
                    }
                }
            @unknown default:
                return
        }
    }

    //handles what occurs in the case that the user has allowed the camera to be accessed
    func accessAllowed()
    {
        DispatchQueue.main.async
        {
            //defaults to the camera if access is allowed
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                //sets delegates and puts up the camera so the user can take a picture of their plants
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .camera
                imagePickerController.allowsEditing = true
                self.present(imagePickerController, animated: true, completion: nil)
            }
            //if the user does not have a camera, it defaults to the camera roll instead of the camera itself
            else
            {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                print("Camera not available so we will use photo library instead")
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.allowsEditing = true
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
    //these functions make sure that their is valid camera access to avoid the app crashing in the case the user did not want to take pictures of their plants (for some reason >:( )
    func presentCameraSettings()
    {
        let alertController = UIAlertController(title: "Error",message: "Camera access is denied", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        present(alertController, animated: true, completion: nil)
    }
    
    //sets the image from the one picked from whatever (camera/camera roll) is used to select or determine the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
        {
            let possibleImage = info[.editedImage] as? UIImage
            plantImage.image = possibleImage!
            debugPrint("setting image!")
            self.dismiss(animated: true, completion: nil)
        }
}
