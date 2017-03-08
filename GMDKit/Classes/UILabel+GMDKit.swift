//
//  UILabel+GMDKit.swift
//  Pods
//
//  Created by Gabriel Morales on 3/8/17.
//
//

import Foundation

extension UILabel{
    public func addTextSpacing(_ spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: text!)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: text!.characters.count))
        attributedText = attributedString
    }
}
