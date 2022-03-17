//
//  plantAboutViewController.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 3/16/22.
//

import UIKit
import SafariServices

class plantAboutViewController: UIViewController {

    @IBOutlet weak var donationTextView: UITextView!
    @IBOutlet weak var donateBtn: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        donateBtn.layer.cornerRadius = 25.0
        donationTextView.layer.cornerRadius = 15.0
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
    
}
