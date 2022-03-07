//
//  segmentedControllerExt.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 3/2/22.
//

import UIKit

class segmentedControllerExt: UISegmentedControl
{
    func defaultConfiguration(font: UIFont = UIFont.boldSystemFont(ofSize: 14), color: UIColor = UIColor.black)
    {
        let defaultAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(defaultAttributes, for: .normal)
    }
}
