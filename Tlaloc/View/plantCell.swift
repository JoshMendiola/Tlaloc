//
//  plantCell.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/20/22.
//

import UIKit

class plantCell: UITableViewCell {
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantSpecies: UILabel!
    
    
    func configureCell(plant: PlantInformation)
    {
        self.plantName.text = plant.plantName
        self.plantSpecies.text = plant.plantSpecies
    }

}
