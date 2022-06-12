//
//  UIview_Extention.swift
//  Sonify
//
//  Created by Meghan Blyth on 09/07/2021.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
    }
}
