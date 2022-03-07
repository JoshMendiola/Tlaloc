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
    @IBOutlet weak var plantName: UITextView!
    @IBOutlet weak var plantSpecies: UITextView!
    @IBOutlet weak var waterDayCount: UITextField!
    @IBOutlet weak var fertilizerDayCount: UITextField!
    @IBOutlet weak var plantCreationBtn: UIButton!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var chooseImgBtn: UIButton!
    @IBOutlet weak var needsFertilizerBtn: UISwitch!
    var currentImage: UIImage = UIImage(named: "pixelplant")!
    var fertilizerAllowed: Bool = true
    
    //handles viewcontroller presentation
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard()
        plantName.delegate = self
        plantSpecies.delegate = self
        plantName.text = String(localized: "Plant Name")
        plantSpecies.text = String(localized: "Plant Species")
        waterDayCount.delegate = self
        fertilizerDayCount.delegate = self
        waterDayCount.layer.cornerRadius = 10.0
        fertilizerDayCount.layer.cornerRadius = 10.0
        plantName.layer.cornerRadius = 10.0
        plantSpecies.layer.cornerRadius = 10.0
        plantImage.layer.cornerRadius = 10.0
        currentImage = UIImage(named: "pixelplant")!
        fertilizerAllowed = true
        plantImage.image = currentImage
        chooseImgBtn.layer.cornerRadius = 10.0
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
        let waterTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day], from: futureWaterDate!), repeats: true)
        
        //makes the water request
        let waterRequest = UNNotificationRequest(identifier: (plants.plantID! + "Water") , content: waterContent, trigger: waterTrigger)
        UNUserNotificationCenter.current().add(waterRequest)
        
        if(plants.needsFertilizer == true)
        {
            //handles the future fertilizer notification doing the same thing
            let fertilizerContent = UNMutableNotificationContent()
            fertilizerContent.title = plants.plantName! + " needs fertilizer !"
            fertilizerContent.subtitle = "Log in now and fertilize your plant"
            fertilizerContent.sound = UNNotificationSound.default
            let fertilizerTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day], from: futureFertilizerDate!), repeats: true)

            //makes fertilizer request
            let fertilizerRequest = UNNotificationRequest(identifier: (plants.plantID! + "Fertilizer"), content: fertilizerContent, trigger: fertilizerTrigger)
            UNUserNotificationCenter.current().add(fertilizerRequest)
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

            plantName.inputAccessoryView = doneToolbar
            plantSpecies.inputAccessoryView = doneToolbar
            waterDayCount.inputAccessoryView = doneToolbar
            fertilizerDayCount.inputAccessoryView = doneToolbar
        }

        @objc func doneButtonAction()
        {
            plantName.resignFirstResponder()
            plantSpecies.resignFirstResponder()
            waterDayCount.resignFirstResponder()
            fertilizerDayCount.resignFirstResponder()
        }
    
        func randomString(length: Int) -> String {
          let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<length).map{ _ in letters.randomElement()! })
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
    
    func accessAllowed()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
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
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
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
}
