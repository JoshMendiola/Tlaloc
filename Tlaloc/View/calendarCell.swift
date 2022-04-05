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
    var wasAnActiveDay: Bool = false
    var selectedDate: Date = Date.init()

    func configureCell(selectedDate: Date, wasAnActiveDay: Bool)
    {
        self.wasAnActiveDay = wasAnActiveDay
        self.selectedDate = selectedDate
        if(wasAnActiveDay)
        {
            plantWasCaredForThatDayBtn.isHidden = false
        }
        else
        {
            plantWasCaredForThatDayBtn.isHidden = true
        }
    }
}
