//
//  plantCreationView.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/26/22.
//

import UIKit
import CoreData
import AVFoundation


class plantCreationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate
{
    //IBOutlets for various buttons and widgets on the screen
    @IBOutlet weak var plantName: UITextView!
    @IBOutlet weak var plantSpecies: UITextView!
    @IBOutlet weak var waterDayCount: UITextField!
    @IBOutlet weak var fertilizerDayCount: UITextField!
    @IBOutlet weak var plantCreationBtn: UIButton!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var chooseImgBtn: UIButton!
    @IBOutlet weak var needsFertilizerBtn: UISwitch!
    
    //variables thatw will be accessed throughout the program, such as the image tha is displayed, wether the plant needs fertilizer or not, and the time in which the user wants to recieve notifications
    var currentImage: UIImage = UIImage(named: "pixelplant")!
    var fertilizerAllowed: Bool = true
    var preferredNotifTime: Date = Date()
    //accessing the user defaults to help with notification scheduling
    let timeKeeper = UserDefaults.standard
    
    //handles viewcontroller presentation
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard()
        
        //sets proper delegation
        plantName.delegate = self
        plantSpecies.delegate = self
        waterDayCount.delegate = self
        fertilizerDayCount.delegate = self
        
        //rounds the corners of various objects
        waterDayCount.layer.cornerRadius = 10.0
        fertilizerDayCount.layer.cornerRadius = 10.0
        plantName.layer.cornerRadius = 10.0
        plantSpecies.layer.cornerRadius = 10.0
        plantImage.layer.cornerRadius = 10.0
        chooseImgBtn.layer.cornerRadius = 25.0
        plantCreationBtn.layer.cornerRadius = 15.0
        
        //sets the minimum font in which the plant creation buttons text can appear in, a difficult button to prettify in terms of its text
        plantCreationBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        plantCreationBtn.titleLabel?.minimumScaleFactor = 0.5
        
        currentImage = UIImage(named: "pixelplant")!
        fertilizerAllowed = true
        plantImage.image = currentImage
        
        
        //handles the desired time of notifications
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
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    //checks if the current inputs into each spot is valid
    func inputIsValid() -> Bool
    {
        if plantName.text != "" && plantSpecies.text != "" && waterDayCount.text != "" && Int16(waterDayCount.text!)! > 0
        {
            if(fertilizerAllowed == false)
            {
                return true
            }
            else if fertilizerAllowed == true && fertilizerDayCount.text != "" && Int16(fertilizerDayCount.text!)! > 0
            {
                return true
            }
        }
        plantCreationBtn.alpha = 0.5
        return false
    }
    
    //handles the back button
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetail()
    }
    
    //deletes placeholder text in the inputs
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.textColor = UIColor.black
        textView.text = ""
    }
    
    //changes button alpha to let user know if they can make their plant
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if inputIsValid()
        {
            plantCreationBtn.alpha = 1.0
        }
    }
    //changes button alpha to let user know if they can make their plant
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if inputIsValid()
        {
            plantCreationBtn.alpha = 1.0
        }
    }
    
    //handles what would happen if the create button was pressed
    @IBAction func createPlantBtnWasPressed(_ sender: Any)
    {
        if inputIsValid()
        {
            self.save { (complete) in
                if complete
                {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    //handles what occurs in the case the user clicks the needs fertilizer button, a button that determines wether a plant actually requires and keeps track of fertilization effects
    @IBAction func needsFertilizerBtnWasPressed(_ sender: Any)
    {
        if needsFertilizerBtn.isOn
        {
            fertilizerDayCount.alpha = 1.0
            fertilizerDayCount.isUserInteractionEnabled = true
            fertilizerAllowed = true
        }
        else
        {
            fertilizerDayCount.alpha = 0.5
            fertilizerDayCount.isUserInteractionEnabled = false
            fertilizerDayCount.text = ""
            fertilizerAllowed = false
        }
        if inputIsValid()
        {
            plantCreationBtn.alpha = 1.0
        }
    }
    
    //calculates the next date to be counted down to
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
    
    //ensures this view controller does not autorotate, an action in which the UI was not designed for
    override open var shouldAutorotate: Bool
    {
        return false
    }
}

//this section handles background stuff, saving to core data, and the addition of a done button on the kyboard
extension plantCreationViewController
{
    //handles the saving of values into coredata
    func save(completion: (_ finished: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else { return }
        let plants = PlantInformation(context: managedContext)
        
        //reassigns all of the core data values to the variables inputted into the screen
        plants.plantName = plantName.text
        plants.plantSpecies = plantSpecies.text
        plants.daysBetweenWater = Int16(waterDayCount.text!)!
        
        //checks if plant needs fertilizer or not
        if fertilizerDayCount.text != ""
        {
            plants.daysBetweenFertilizer = Int16(fertilizerDayCount.text!)!
            plants.needsFertilizer = true
        }
        else
        {
            plants.needsFertilizer = false
        }
        
        //continues inputting values further into coredata set
        let (futureFertilizerDate,futureWaterDate) = calculateNextDate(waterDayCount: plants.daysBetweenWater, fertilizerDayCount: plants.daysBetweenFertilizer)
        plants.nextWaterDate = futureWaterDate
        plants.nextFertilizerDate = futureFertilizerDate
        plants.plantID = randomString(length: 8)
        plants.plantImage = currentImage.pngData()
        
        //attempts to save, throwing an error if there is a failure
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
        
        //handles the future water notification by making a content, setting its values and converting it into a notification request
        let waterContent = UNMutableNotificationContent()
        waterContent.title = plants.plantName! + " needs water !"
        waterContent.subtitle = "Log in now and water your plant"
        waterContent.sound = UNNotificationSound.default
        
        //adds the desired time and desired date together
        let futureWaterNotifTime = combineDateWithTime(date: futureWaterDate!, time: preferredNotifTime)
        
        //makes the water request
        let waterTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day,.hour,.minute], from: futureWaterNotifTime!), repeats: true)
        let waterRequest = UNNotificationRequest(identifier: (plants.plantID! + "Water") , content: waterContent, trigger: waterTrigger)
        UNUserNotificationCenter.current().add(waterRequest)
        
        if(plants.needsFertilizer == true)
        {
            //handles the future fertilizer notification doing the same thing
            let fertilizerContent = UNMutableNotificationContent()
            fertilizerContent.title = plants.plantName! + " needs fertilizer !"
            fertilizerContent.subtitle = "Log in now and fertilize your plant"
            fertilizerContent.sound = UNNotificationSound.default
            
            //adds the desired time and desired date together
            let futureFertilizerNotifTime = combineDateWithTime(date: futureFertilizerDate!, time: preferredNotifTime)

            //makes fertilizer request
            let fertilizerTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day,.hour,.minute], from: futureFertilizerNotifTime!), repeats: true)
            let fertilizerRequest = UNNotificationRequest(identifier: (plants.plantID! + "Fertilizer"), content: fertilizerContent, trigger: fertilizerTrigger)
            UNUserNotificationCenter.current().add(fertilizerRequest)
        }
    }
    
    //a function that adds a done button onto a keyboard that allows it to be dismissed in the case that a user is done typing when using it
    func addDoneButtonOnKeyboard()
    {
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            plantName.inputAccessoryView = doneToolbar
            plantSpecies.inputAccessoryView = doneToolbar
            waterDayCount.inputAccessoryView = doneToolbar
            fertilizerDayCount.inputAccessoryView = doneToolbar
        }

        //ab obective C function that provides functionality to when the done button on the keyboard is pressed, resigning, or disappearing, the keyboard thta is currently displayed
        @objc func doneButtonAction()
        {
            plantName.resignFirstResponder()
            plantSpecies.resignFirstResponder()
            waterDayCount.resignFirstResponder()
            fertilizerDayCount.resignFirstResponder()
        }
    
        //creates a randomized string from the list of letters, this is key in creating different plant ID's which make processing them in the core data objects much easier
        func randomString(length: Int) -> String
        {
          let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<length).map{ _ in letters.randomElement()! })
        }
    
        //combines the date from a date object and a time from another date object to create one mega date, this date is used in processing when to schedule notifications when the plant is created
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

//handles the camera and photo library
extension plantCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    //handles what happens if the choose image button is pressed
    @IBAction func chooseImgBtnWasPressed(_ sender: Any)
    {
        checkCameraAccess()
    }
    
    //sets the image with the new one taken
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
        {
            let possibleImage = info[.editedImage] as? UIImage
            currentImage = possibleImage!
            debugPrint("setting image!")
            plantImage.image = currentImage
            self.dismiss(animated: true, completion: nil)
        }
    
    //checks if the app has access to the camera or camera roll, in the case that it does not, it will handle what to do next
    func checkCameraAccess()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied:
                //gives the user the option to change the app settings in the case that the user did not give access to the camera
                print("Denied, request permission from settings")
                presentCameraSettings()
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                //handles what happens in the case that the camera is allowed for use
                print("Authorized, proceed")
                accessAllowed()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        print("Permission granted, proceed")
                        self.accessAllowed()
                    } else {
                        print("Permission denied")
                    }
                }
            @unknown default:
                return
            }
        }
    
    //handles what happens in the case camera access is allowed
    func accessAllowed()
    {
        DispatchQueue.main.async
        {
            //defaults to using the user camera if available
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .camera
                imagePickerController.allowsEditing = true
                self.present(imagePickerController, animated: true, completion: nil)
            }
            //otherwise, uses the camera roll or saved images in the device
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
                })
            }
        })
        present(alertController, animated: true, completion: nil)
    }
}
