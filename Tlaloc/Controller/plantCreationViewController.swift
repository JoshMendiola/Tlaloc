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
    
    func save(completion: (_ finished: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else { return }
        let plants = PlantInformation(context: managedContext)
        
        plants.plantName = plantName.text
        plants.plantSpecies = plantSpecies.text
        plants.timeUntilWater = Int32(waterDayCount.text!)!
        plants.timeUntilFertilizer = Int32(fertilizerDayCount.text!)!
        
        
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
