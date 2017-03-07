//
//  Storyboard.swift
//  Pods
//
//  Created by Gabriel Morales on 3/7/17.
//
//

import Foundation
import UIKit

enum AppStoryboard : String {
    case Main
    case MapDetail
    
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass : T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("Viewcontroller with ID \(storyboardID), not found in \(self.rawValue) Storyboard")
        }
        
        return scene
    }
}


extension UIViewController {
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard : AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
}
