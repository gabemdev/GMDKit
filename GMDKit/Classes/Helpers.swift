//
//  Helpers.swift
//  Pods
//
//  Created by Gabriel Morales on 3/7/17.
//
//

import UIKit

public class Helpers: NSObject {
    
    
    /// Get dictionary from any PLIST
    ///
    /// - Parameter plist: Any file of plist type
    /// - Returns: Optional NSDictionary
    public class func getDictionaryFromPlist(plist: String) -> NSDictionary? {
        guard let path = Bundle.main.path(forResource: plist, ofType: "plist") else { return nil }
        let dict = NSDictionary(contentsOfFile: path)
        return dict
    }
}

