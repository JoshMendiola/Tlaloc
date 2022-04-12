//
//  activityCell.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 4/11/22.
//

import UIKit

class activityCell: UITableViewCell
{
    //Iboutlet for the text field of the activity cell
    @IBOutlet weak var plantName: UILabel!
    
    //this configures the cell using the plantcalendar object passed into it
    func configureCell(plantActivity: PlantCalendar)
    {
        //sets the standard look of the cells
        self.layer.cornerRadius = 15.0
        
        //checks to determine color of the cell based on if it was watered or fertilized
        if(plantActivity.wasWatered == true)
        {
            self.backgroundColor = UIColor.systemBlue
        }
        else
        {
            self.backgroundColor = UIColor.systemBrown
        }
        
        //sets the text field based of the plant name passed into it
        plantName.text = plantActivity.plantCaredFor
    }

}
