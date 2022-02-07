//
//  plantCreationView.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/26/22.
//

import UIKit
import CoreData



class plantCreationViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var plantName: UITextView!
    @IBOutlet weak var plantSpecies: UITextView!
    @IBOutlet weak var waterDayCount: UITextField!
    @IBOutlet weak var fertilizerDayCount: UITextField!
    @IBOutlet weak var plantCreationBtn: UIButton!
    
    //handles viewcontroller presentation
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard()
        plantName.delegate = self
        plantSpecies.delegate = self
        waterDayCount.delegate = self
        fertilizerDayCount.delegate = self
        waterDayCount.layer.cornerRadius = 5.0
        fertilizerDayCount.layer.cornerRadius = 5.0
        plantName.layer.cornerRadius = 8.0
        plantSpecies.layer.cornerRadius = 8.0
    }
    
    //checks if the current inputs into each spot is valid
    func inputIsValid() -> Bool
    {
        if plantName.text != "" && plantSpecies.text != "" && waterDayCount.text != "" && fertilizerDayCount.text != "" && fertilizerDayCount.text != "" && Int(waterDayCount.text!)! > 0 && Int(fertilizerDayCount.text!)! > 0
        {
            return true
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
    
    //calculates the next date to be counted down to
    func calculateNextDate() -> (Date?, Date?)
    {
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let currentDate = Calendar.current.date(from: dateComponents)
        let futureWaterDate = Calendar.current.date(byAdding: .day, value: Int(waterDayCount.text!)!, to: date)!
        let futureFertilizerDate = Calendar.current.date(byAdding: .day, value: Int(fertilizerDayCount.text!)!, to: date)!
        
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
        
        let (futureFertilizerDate,futureWaterDate) = calculateNextDate()
        
        plants.nextWaterDate = futureWaterDate
        plants.nextFertilizerDate = futureFertilizerDate
        plants.plantName = plantName.text
        plants.plantSpecies = plantSpecies.text
        
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
}
