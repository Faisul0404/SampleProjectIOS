//
//  Extentions.swift
//  Copyright © 2019 Elegant Media Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

extension Dictionary {
    // To Update Parameter dictionary
    mutating func updateDictionary(otherValues: Dictionary) {
        for (key, value) in otherValues {
            self.updateValue(value, forKey: key)
        }
    }
    
    func nullKeyRemoval() -> Dictionary {
        var dict = self
        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull || ((dict[$0] as? Int) == 0) || ((dict[$0] as? String) == "") }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }
        return dict
    }
}
