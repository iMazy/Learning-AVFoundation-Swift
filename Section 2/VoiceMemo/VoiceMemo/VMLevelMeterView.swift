//
//  VMLevelMeterView.swift
//  VoiceMemo
//
//  Created by Mazy on 2020/9/10.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class VMLevelMeterView: UIView {

    public var level: CGFloat = 0
    public var peakLevel: CGFloat = 0
    
    private lazy var ledCount: Int = 20
    private lazy var ledBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.35)
    //
    private lazy var ledBorderColor: UIColor = UIColor.black
    //
    private lazy var colorThresholds: [UIColor] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        let greenColor = UIColor(red: 0.458, green: 1.000, blue: 0.396, alpha: 1.000)
        let yellowColor = UIColor(red: 1.000, green: 0.930, blue: 0.315, alpha: 1.000)
        let redColor = UIColor(red: 1.000, green: 0.325, blue: 0.329, alpha: 1.000)
        
        colorThresholds = [greenColor, yellowColor, redColor]
    }
    
    func resetLevelMeter() {
        self.level = 0.0
        self.peakLevel = 0.0
        self.setNeedsDisplay()
    }
    
    func clamp(intensity: CGFloat) -> CGFloat {
        if (intensity < 0.0) {
            return 0.0
        } else if (intensity >= 1.0) {
            return 1.0
        } else {
            return intensity
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }

        var peakLED: Int = 1

        if (self.peakLevel > 0) {
            peakLED = Int(self.peakLevel * CGFloat(self.ledCount))
            if (peakLED >= self.ledCount) {
                peakLED = self.ledCount - 1
            }
        }
        
        for index in 0..<ledCount {
            let height = self.bounds.height
            let width = self.bounds.width
            let ledRect = CGRect(x: CGFloat(index)/CGFloat(self.ledCount) * width, y: 0, width: width * CGFloat(1.0 / Double(self.ledCount)), height: height)
            context.setFillColor(UIColor.black.cgColor)
            context.fill(ledRect)
        }
        
        for index in 0..<peakLED {
            
            var ledColor = colorThresholds[0]
            
            let range = CGFloat(index) / CGFloat(ledCount)
            if range < 0.33 {
                ledColor = colorThresholds[0]
            } else if range < 0.66 {
                ledColor = colorThresholds[1]
            } else {
                ledColor = colorThresholds[2]
            }

            let height = self.bounds.height
            let width = self.bounds.width
            let ledRect = CGRect(x: CGFloat(index)/CGFloat(self.ledCount) * width, y: 0, width: width * CGFloat(1.0 / Double(self.ledCount)), height: height)
            context.setFillColor(ledColor.cgColor)
            context.fill(ledRect)
            
            let fillPath = UIBezierPath(roundedRect: ledRect, cornerRadius: 2.0)
            context.addPath(fillPath.cgPath)
            context.setStrokeColor(self.ledBorderColor.cgColor)
            context.drawPath(using: .stroke)
            
        }
    }
}
