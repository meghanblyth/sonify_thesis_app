//
//  UIImage+Extension.swift
//  Sonify
//
//  Created by Meghan Blyth on 25/07/2021.
//

import UIKit

extension UIImage {
    func getPixelColor(pos: CGPoint) -> (UIColor, CGFloat, CGFloat) {
        guard let pixelData = self.cgImage?.dataProvider?.data else { return (.black, 255, 255) }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo])
        let g = CGFloat(data[pixelInfo+1])
        let b = CGFloat(data[pixelInfo+2])
        let a = CGFloat(data[pixelInfo+3])
        
        return (UIColor(red: r/255, green: g/255, blue: b/255, alpha: a/255), (r+g+b)/3, 200)               //determining that draker colours have a lower value which will lead to a lower frequency.
        
    }
}

