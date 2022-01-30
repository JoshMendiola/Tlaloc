//
//  plantCreationView.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/26/22.
//

import UIKit
import CoreData



class plantCreationViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var plantName: UITextView!
    @IBOutlet weak var plantSpecies: UITextView!
    @IBOutlet weak var waterDayCount: UITextField!
    @IBOutlet weak var fertilizerDayCount: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        plantName.delegate = self
        plantSpecies.delegate = self
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
    
    @IBAction func createPlantBtnWasPressed(_ sender: Any)
    {
        if plantName.text != "" && plantSpecies.text != ""
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
}
