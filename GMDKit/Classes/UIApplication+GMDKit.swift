//
//  UIApplication+GMDKit.swift
//  Pods
//
//  Created by Gabriel Morales on 3/13/17.
//
//

import UIKit

public extension UIApplication {
    /**
     The window used for presenting the root level of the user interface.
     */
    var mainWindow: UIWindow? {
        guard let window = delegate?.window else {
            print("Error: No main window!")
            return nil
        }
        
        guard let windowToReturn = window else {
            print("Error: No main window!")
            return nil
        }
        
        return windowToReturn
    }
    
    /**
     The current top-most view controller, suitable for presenting an alert controller from.
     */
    var topmostViewController: UIViewController? {
        guard let rootViewController = mainWindow?.rootViewController else {
            return nil
        }
        
        return topmostViewControllerWithRootViewController(rootViewController)
    }
    
    private func topmostViewControllerWithRootViewController(_ rootViewController: UIViewController) -> UIViewController {
        if let presented = rootViewController.presentedViewController {
            return topmostViewControllerWithRootViewController(presented)
        }
        else if let navigationController = rootViewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return topmostViewControllerWithRootViewController(visibleViewController)
        }
        else if let lastChild = rootViewController.childViewControllers.last {
            return lastChild
        }
        else {
            return rootViewController
        }
    }
}

