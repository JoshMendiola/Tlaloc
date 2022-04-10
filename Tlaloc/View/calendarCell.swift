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
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var plantWasCaredForThatDayBtn: UIButton!
    weak var delegate: calendarCellDelegate?
    var wasAnActiveDay: Bool = false
    var selectedDate: Date = Date.init()

    func configureCell(selectedDate: Date, wasAnActiveDay: Bool)
    {
        self.wasAnActiveDay = wasAnActiveDay
        self.selectedDate = selectedDate
        if(wasAnActiveDay)
        {
            plantWasCaredForThatDayBtn.isHidden = false
            self.backgroundColor = UIColor(displayP3Red: 235/256, green: 168/256, blue: 69/256, alpha: 1.0)
            self.plantWasCaredForThatDayBtn.layer.cornerRadius = 15.0
            debugPrint("This is the date that the cell took in")
            debugPrint(selectedDate)
        }
        else
        {
            plantWasCaredForThatDayBtn.isHidden = true
            self.backgroundColor = UIColor(displayP3Red: 235/256, green: 168/256, blue: 69/256, alpha: 1.0)
        }
    }
    
    func configureNonDateCell()
    {
        plantWasCaredForThatDayBtn.isHidden = true
        self.backgroundColor = UIColor(displayP3Red: 247/256, green: 204/256, blue: 134/256, alpha: 1.0)
    }
    
    func getSelectedDate() -> Date
    {
        return self.selectedDate
    }
    
    @IBAction func plantActivityBtnWasPressed(_ sender: Any)
    {
        delegate?.plantActivityBtnWasPressed(delegatedFrom: self)
        
    }
    
}

protocol calendarCellDelegate: AnyObject
{
    func plantActivityBtnWasPressed(delegatedFrom cell: calendarCell)
}
