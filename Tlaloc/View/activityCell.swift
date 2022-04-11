//
//  activityCell.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 4/11/22.
//

import UIKit

class activityCell: UITableViewCell
{
    @IBOutlet weak var plantName: UILabel!
    
    func configureCell(plantActivity: PlantCalendar)
    {
        plantName.text = plantActivity.plantCaredFor
    }

}
