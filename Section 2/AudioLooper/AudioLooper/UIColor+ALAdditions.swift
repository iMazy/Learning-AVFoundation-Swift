//
//  UIColor+ALAdditions.swift
//  AudioLooper
//
//  Created by Mazy on 2020/9/8.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

extension UIColor {
    
    var lighterColor: UIColor? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 1
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: min(brightness * 1.3, 1.0), alpha: 0.5)
        }
        return nil
    }
    
    var darkerColor: UIColor? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 1
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.92, alpha: alpha)
        }
        return nil
    }
}
