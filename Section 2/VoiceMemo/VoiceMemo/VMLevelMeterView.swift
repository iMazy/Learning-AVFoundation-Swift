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
    private lazy var colorThresholds: [THLevelMeterColorThreshold] = []
    
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
        
        colorThresholds = [THLevelMeterColorThreshold(name: "green", color: greenColor, maxValue: 0.5),
                           THLevelMeterColorThreshold(name: "yellow", color: yellowColor, maxValue: 0.8),
                           THLevelMeterColorThreshold(name: "red", color: redColor, maxValue: 1.0)]
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
        context.translateBy(x: 0, y: self.bounds.height)
        context.rotate(by: -CGFloat.pi / 2)

//        let bounds = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.width)
        
        var lightMinValue: Float = 0.0

        var peakLED: Int = -1

        if (self.peakLevel > 0) {
            peakLED = Int(self.peakLevel * CGFloat(self.ledCount))
            if (peakLED >= self.ledCount) {
                peakLED = self.ledCount - 1
            }
        }

        for index in 0..<ledCount {
            var ledColor = colorThresholds[0].color
            let ledMaxValue: CGFloat = CGFloat((index + 1) / self.ledCount)
            
            for index in 0..<(self.colorThresholds.count - 1) {
                let currThreshold = colorThresholds[index]
                let nextThreshold = colorThresholds[index + 1]
                
                if currThreshold.maxValue > ledMaxValue {
                    ledColor = nextThreshold.color
                }
            }
     
            let height = self.bounds.height
            let width = self.bounds.width
            let ledRect = CGRect(x: 0, y: height * CGFloat(index/self.ledCount), width: width, height: height * CGFloat(1.0 / Double(self.ledCount)))
            
            context.setFillColor(self.ledBackgroundColor.cgColor)
            context.fill(ledRect)
            
            // Draw Light
            var lightIntensity: CGFloat = 0
            if index == peakLED {
                lightIntensity = 1.0
            } else {
                lightIntensity = self.clamp(intensity: (self.level - CGFloat(lightMinValue)) / (ledMaxValue - CGFloat(lightMinValue)))
            }
            
            var fillColor: UIColor?
            if lightIntensity == 1 {
                fillColor = ledColor
            } else if lightIntensity > 0 {
                if let color = ledColor?.cgColor.copy(alpha: lightIntensity) {
                    fillColor = UIColor(cgColor: color)
                } else {
                    fillColor = ledColor
                }
            }
            
            if let fillcgColor = fillColor?.cgColor {
                context.setFillColor(fillcgColor)
            }
            let fillPath = UIBezierPath(roundedRect: ledRect, cornerRadius: 2.0)
            context.addPath(fillPath.cgPath)
            
            context.setStrokeColor(self.ledBorderColor.cgColor)
            let strokePath = UIBezierPath(roundedRect: ledRect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2.0)
            
            context.addPath(strokePath.cgPath)
            context.drawPath(using: .fillStroke)
            
            lightMinValue = Float(ledMaxValue)
        }
    }
}

class THLevelMeterColorThreshold: NSObject {
    
    var maxValue: CGFloat!
    var color: UIColor!
    var name: String!

    convenience init(name: String, color: UIColor, maxValue: CGFloat) {
        //这里也是要明确调用self.init()
        self.init()
        
        self.maxValue = maxValue
        self.color = color
        self.name = name
    }
    
}
