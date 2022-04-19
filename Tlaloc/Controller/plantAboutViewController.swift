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
    
    //these are all IBOutlets connecting to the various featurss of the view controller, each working to maintain the look and function of the VC. The userdefaults is also included in order to be able to save the time in which notifications are to be set, which should be able to be changed on this page
    @IBOutlet weak var donationTextView: UITextView!
    @IBOutlet weak var donateBtn: UIButton!
    @IBOutlet weak var notifTimePicker: UIDatePicker!
    @IBOutlet weak var confirmTimeBtn: UIButton!
    let timeKeeper = UserDefaults.standard
    
    override func viewDidLoad()
    {
        
        //sets up UI attributes such as rounding corners and text colors
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
            //correctly formats the default value in which the user has never altered the notification time before, formatting it correctly so it can be altered in the future. the default time is midnight
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let someDateTime = formatter.date(from: "00:00:00")
            notifTimePicker.date = someDateTime!
        }
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
    
    //dismisses the view controller in the case the back button was pressed
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetailFromRight()
    }
    
    //stops the view controller from autorotating, locking the viewcontroller in the upright orientation
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
}
