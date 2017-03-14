//
//  Storyboard.swift
//  Pods
//
//  Created by Gabriel Morales on 3/7/17.
//
//

import Foundation
import UIKit

public enum AppStoryboard : String {
    case Main
    case MapDetail
    
    public var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    public func viewController<T: UIViewController>(viewControllerClass : T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("Viewcontroller with ID \(storyboardID), not found in \(self.rawValue) Storyboard")
        }
        
        return scene
    }
}


public extension UIViewController {
    public class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard : AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    /// Utility that presents an alert with 1 dismissal action.
    ///
    /// - Parameters:
    ///   - title: Any string for alert title.
    ///   - message: Any string for alert message.
    public func showAlert(withTitle title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    public var contentViewController: UIViewController {
        if let navController = self as? UINavigationController {
            return navController.visibleViewController!
        } else {
            return self
        }
    }
    
    public func dismissAnyModalChildren(animated: Bool, withCompletion completion: (() -> ())?) {
        if presentedViewController != nil {
            dismiss(animated: animated, completion: completion)
        }
        else {
            for child in childViewControllers {
                child.dismissAnyModalChildren(animated: animated, withCompletion: nil)
            }
            completion?()
        }
    }
}
