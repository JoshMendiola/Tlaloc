//
//  ViewControllerExt.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 1/25/22.
//

import UIKit

extension UIViewController
{
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
    
    func dismissDetail()
    {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false, completion: nil)
    }
    
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
