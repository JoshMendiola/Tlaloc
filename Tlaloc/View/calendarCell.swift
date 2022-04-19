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
    //creates IBoutlets forte objects within the cell
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var plantWasCaredForThatDayBtn: UIButton!
    
    //sets the delegate and intializes all values to 0 (until so changed by the cell configuration)
    weak var delegate: calendarCellDelegate?
    var wasAnActiveDay: Bool = false
    var selectedDate: Date = Date.init()
    var selectedDateDay: Int = 0
    var selectedDateMonth: Int = 0
    var selectedDateYear: Int = 0

    //works to configure the details of the cell corresponding to the data past into it, holding selected date and using wasAnActiveDay to determine if it should display the button or not
    func configureCell(selectedDate: Date, wasAnActiveDay: Bool)
    {
        //initalizes all of the variables created above
        self.wasAnActiveDay = wasAnActiveDay
        self.selectedDate = selectedDate
        self.selectedDateDay = Calendar.current.dateComponents([.day], from: selectedDate).day!
        self.selectedDateMonth = Calendar.current.dateComponents([.month], from: selectedDate).month!
        self.selectedDateYear = Calendar.current.dateComponents([.year], from: selectedDate).year!
        
        plantWasCaredForThatDayBtn.isHidden = false
        self.backgroundColor = UIColor(displayP3Red: 235/256, green: 168/256, blue: 69/256, alpha: 1.0)
        
        //checks if this cell has any acitivity associated with it, displaying the button in the case it does, not displaying it in the case it does not
        if(wasAnActiveDay)
        {
            //if day was active, rounds off the button to prettify the calendar
            self.plantWasCaredForThatDayBtn.layer.cornerRadius = 15.0
        }
    }
    
    //handles how the cell should appear in the case it does not correspond to a day on the calendar
    func configureNonDateCell()
    {
        plantWasCaredForThatDayBtn.isHidden = true
        self.backgroundColor = UIColor(displayP3Red: 247/256, green: 204/256, blue: 134/256, alpha: 1.0)
    }
    
    //handles what occurs in the case the plantacitivtybtn was pressed, using the delegate passed to the plantListViewController to properly display the functions needed there
    @IBAction func plantActivityBtnWasPressed(_ sender: Any)
    {
        delegate?.plantActivityBtnWasPressed(dateToShow: selectedDate)
    }
    
}

//sets abstract functions required by the delegate
protocol calendarCellDelegate: AnyObject
{
    func plantActivityBtnWasPressed(dateToShow: Date)
}
