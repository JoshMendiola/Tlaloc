//
//  plantAboutViewController.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 3/16/22.
//

import UIKit
import SafariServices
import CoreData

class plantAboutViewController: UIViewController {

    var TimeData: [TimeData] = []
    @IBOutlet weak var donationTextView: UITextView!
    @IBOutlet weak var donateBtn: UIButton!
    @IBOutlet weak var confirmTimeBtn: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        donateBtn.layer.cornerRadius = 25.0
        donationTextView.layer.cornerRadius = 15.0
        confirmTimeBtn.layer.cornerRadius = 15.0
    }
    @IBAction func backBtnWasPressed(_ sender: Any)
    {
        dismissDetailFromRight()
    }
    @IBAction func donateBtnWasPressed(_ sender: Any)
    {
        let url = URL(string: "https://plantwithpurpose.org/what-we-do/mexico/?location=mx")
        let svc = SFSafariViewController(url: url!)
        present(svc, animated: true, completion: nil)
    }
    @IBAction func confirmTimeBtnWasPressed(_ sender: Any)
    {
        
    }
    
}

extension plantAboutViewController
{
    func fetch(completion: (_ complete: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let fetchRequest = NSFetchRequest<TimeData>(entityName: "TimeData")
        
        do
        {
            TimeData = try managedContext.fetch(fetchRequest)
            completion(true)
        }
        catch
        {
            debugPrint("Could not fetch :( : \(error.localizedDescription)")
            completion(false)
        }
    }
    func save(completion: (_ finished: Bool) -> ())
    {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else { return }
        
        do
        {
            try managedContext.save()
            completion(true)
        }
        catch
        {
            debugPrint("Could not save !: \(error.localizedDescription)")
            completion(false)
        }
    }
}
