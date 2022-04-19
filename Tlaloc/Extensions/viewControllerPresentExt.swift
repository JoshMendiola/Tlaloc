//
//  ViewControllerExt.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/25/22.
//

import UIKit

extension UIViewController
{
    //this function makes a view controller appear as if coming from the right, returning no value and written to streamline the animation that follows from trying to switch view controllers
    func presentDetail(_ viewControllerToPresent: UIViewController)
    {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    //this is the same but instead appears from the left
    func presentDetailFromLeft(_ viewControllerToPresent: UIViewController)
    {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    
    //this handles viewcontroller dismissal, going back to the previous view controller from the left
    func dismissDetail()
    {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false, completion: nil)
    }
    //this does the same but from the right
    func dismissDetailFromRight()
    {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false, completion: nil)
    }
}
