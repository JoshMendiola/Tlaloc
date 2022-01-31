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
    
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetail()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.textColor = UIColor.black
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        debugPrint("bingus")
        if plantName.text != "" && plantSpecies.text != "" && waterDayCount.text != "" && fertilizerDayCount.text != ""
        {
            plantCreationBtn.alpha = 1.0
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        debugPrint("bingus")
        if plantName.text != "" && plantSpecies.text != "" && waterDayCount.text != "" && fertilizerDayCount.text != ""
        {
            plantCreationBtn.alpha = 1.0
        }
    }
    
    @IBAction func createPlantBtnWasPressed(_ sender: Any)
    {
        if plantName.text != "" && plantSpecies.text != "" && waterDayCount.text != "" && fertilizerDayCount.text != ""
        {
            self.save { (complete) in
                if complete
                {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
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
