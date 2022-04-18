//
//  plantAboutViewController.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 3/16/22.
//

import UIKit
import SafariServices

class plantAboutViewController: UIViewController
{
    @IBOutlet weak var donationTextView: UITextView!
    @IBOutlet weak var donateBtn: UIButton!
    @IBOutlet weak var notifTimePicker: UIDatePicker!
    @IBOutlet weak var confirmTimeBtn: UIButton!
    let timeKeeper = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        donateBtn.layer.cornerRadius = 25.0
        donationTextView.layer.cornerRadius = 15.0
        confirmTimeBtn.layer.cornerRadius = 15.0
        notifTimePicker.setValue(UIColor.black, forKey: "textColor")
        
        //calculates the proper date and time with the new set notification time
        if timeKeeper.object(forKey: "desiredTime") != nil
        {
            notifTimePicker.date = (timeKeeper.object(forKey: "desiredTime") as? Date)!
        }
        else
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let someDateTime = formatter.date(from: "00:00:00")
            notifTimePicker.date = someDateTime!
        }
    }
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetailFromRight()
    }
    //url leading to the plantwithaprupose page
    @IBAction func donateBtnWasPressed(_ sender: Any)
    {
        let url = URL(string: "https://plantwithpurpose.org/what-we-do/mexico/?location=mx")
        let svc = SFSafariViewController(url: url!)
        present(svc, animated: true, completion: nil)
    }
    //sets the time specificed in the scroller
    @IBAction func confirmTimeBtnWasPressed(_ sender: Any)
    {
        timeKeeper.set(notifTimePicker.date, forKey: "desiredTime")
        dismissDetailFromRight()
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
}
