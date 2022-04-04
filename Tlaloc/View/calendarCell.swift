//
//  CalenderCell.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 4/3/22.
//

import UIKit
import CoreData

class calendarCell: UICollectionViewCell
{
    var plantCalendar: [PlantCalendar] = []
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var plantWasCaredForThatDayBtn: UIButton!
    var wasAnActiveDay: Bool = false
}



//this handles the core data aspect of the calendar cell
extension calendarCell
{
    func fetch(completion: (_ complete: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchRequest = NSFetchRequest<PlantCalendar>(entityName: "PlantCalendar")
        
        do
        {
            plantCalendar = try managedContext.fetch(fetchRequest)
            completion(true)
        }
        catch
        {
            debugPrint("Could not fetch plantcalender :( : \(error.localizedDescription)")
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
    func fetchCoreDataObjects()
    {
        self.fetch { (complete) in
            if complete
            {
                
            }
        }
    }
}
