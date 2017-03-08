//
//  UIColor+GMDKit.swift
//  Pods
//
//  Created by Gabriel Morales on 3/8/17.
//
//

import Foundation

extension UIColor {
    
    public class func color(_ r: Int, g: Int, b: Int) -> UIColor {
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1.0)
    }
}
