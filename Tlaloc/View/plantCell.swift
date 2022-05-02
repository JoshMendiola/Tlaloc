//
//  plantCell.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/20/22.
//

import UIKit

class plantCell: UITableViewCell
{
    //IBOutlets of the cell components
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantSpecies: UILabel!
    @IBOutlet weak var dayCount: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantActionImage: UIImageView!
    
    //configures the cell properly
    func configureCell(plant: PlantInformation, tableChoice: Int)
    {
        //sets text boxes of cell to the ones saved in the core data entity
        self.plantName.text = plant.plantName
        self.plantSpecies.text = plant.plantSpecies
        var img: UIImage
        
        //checks if the plant has an image associated with it, if not, it defaults to the default image
        if plant.plantImage == nil
        {
            img = UIImage(named: "pixelplant")!
        }
        else
        {
            img = UIImage(data: plant.plantImage!)!
        }
        
        //sets image
        self.plantImage.image = img
        
        //checks if table should show water count or fertilizer count
        let date = Date()
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let currentDate = Calendar.current.date(from: dateComponents)!
        
        //checks if the user wants to see the watercount
        if tableChoice == 0
        {
            let timeUntilWater = Calendar.current.dateComponents([.day], from: currentDate, to: plant.nextWaterDate!).day!
            plantActionImage.image = UIImage(named: "tlalocwater")!
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
            plantActionImage.image = UIImage(named: "tlalocfert")!
                dayCount.text = ("-")
        }
        
        //checks if the user wants to see fertilizer and the plant DOES need to be fertilized
        else if tableChoice == 1 && plant.needsFertilizer == true
        {
            //calculates amount of days until the date saved in the core data entity
            let timeUntilFertilizer = Calendar.current.dateComponents([.day], from: currentDate, to: plant.nextFertilizerDate!).day!
            plantActionImage.image = UIImage(named: "tlalocfert")!
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

