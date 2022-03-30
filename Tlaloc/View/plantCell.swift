//
//  plantCell.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/20/22.
//

import UIKit

class plantCell: UITableViewCell
{
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantSpecies: UILabel!
    @IBOutlet weak var dayCount: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
    
    //configures the cell properly
    func configureCell(plant: PlantInformation, tableChoice: Int)
    {
        self.plantName.text = plant.plantName
        self.plantSpecies.text = plant.plantSpecies
        var img: UIImage
        if plant.plantImage == nil
        {
            img = UIImage(named: "pixelplant")!
        }
        else
        {
            img = UIImage(data: plant.plantImage!)!
        }
        self.plantImage.image = img
        //checks if table should show water count or fertilizer count
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let currentDate = Calendar.current.date(from: dateComponents)!
        //checks if the user wants to see the watercount
        if tableChoice == 0
        {
            let timeUntilWater = Calendar.current.dateComponents([.day], from: currentDate, to: plant.nextWaterDate!).day!
            if(timeUntilWater <= 0)
            {
                dayCount.text = String("0")
            }
            else
            {
                dayCount.text = (String(timeUntilWater))
            }
        }
        //checks if the user wants to see fertilizer and the plant does not need to be fertilized
        else if tableChoice == 1 && plant.needsFertilizer == false
        {
                dayCount.text = ("-")
        }
        //checks if the user wants to see fertilizer and the plant DOES need to be fertilized
        else if tableChoice == 1 && plant.needsFertilizer == true
        {
            let timeUntilFertilizer = Calendar.current.dateComponents([.day], from: currentDate, to: plant.nextFertilizerDate!).day!
            if(timeUntilFertilizer <= 0)
            {
                dayCount.text = String("0")
            }
            else
            {
                dayCount.text = (String(timeUntilFertilizer))
            }
        }
    }
}

