//
//  ALControlKnob.swift
//  AudioLooper
//
//  Created by Mazy on 2020/9/8.
//  Copyright © 2020 mazy. All rights reserved.
//

import Foundation
import UIKit

let kMaxAngle: CGFloat = 120
let kScalingFactor: CGFloat = 4.0

class ALControlKnob: UIControl {

    var defaultValue: CGFloat = 0
    var maximumValue: CGFloat = -1
    var minimumValue: CGFloat = 1
    var value: CGFloat = 0
    
    private var angle: CGFloat = 0
    private var touchOrigin: CGPoint = CGPoint.zero
    private lazy var indicatorView: ALIndicatorLight = ALIndicatorLight(frame: self.bounds)
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        backgroundColor = .clear
        indicatorView.lightColor = UIColor.white
        self.addSubview(indicatorView)
        
    }
    
/// pragma mark - Data Model
    func clampAngle(_ angle: CGFloat) -> CGFloat {
        if angle < -kMaxAngle {
            return -kMaxAngle
        } else if angle > kMaxAngle {
            return kMaxAngle
        }
        return angle
    }
    
    func angleForValue(_ value: CGFloat) -> CGFloat {
        return ((value - self.minimumValue) / (self.maximumValue - self.minimumValue) - 0.5) * kMaxAngle * 2
    }
    
    func valueForAngle(_ angle: CGFloat) -> CGFloat {
        return (angle / (kMaxAngle * 2) + 0.5) * (self.maximumValue - self.minimumValue) + self.minimumValue
    }
    
    func valueForPosition(_ point: CGPoint) -> CGFloat {
        let delta: CGFloat = self.touchOrigin.y / point.y
        let newAngle = self.clampAngle(delta * kScalingFactor + self.angle)
        return self.valueForAngle(newAngle)
    }
    
    func setValue(_ newValue: CGFloat, animated: Bool) {
        let oldValue = self.value
        if (newValue < self.minimumValue) {
            self.value = self.minimumValue;
        } else if (newValue > self.maximumValue) {
            self.value = self.maximumValue;
        } else {
            self.value = newValue;
        }

        self.valueDidChangeFrom(oldValue, newValue: self.value, animated: animated)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        self.touchOrigin = point
        self.angle = self.angleForValue(self.value)
        self.isHighlighted = true
        self.setNeedsDisplay()
        return true
    }
    
    func handleTouch(touch: UITouch) -> Bool {
        if touch.tapCount > 1 {
            self.setValue(self.defaultValue, animated: true)
            return false
        }
        let point = touch.location(in: self)
        self.value = self.valueForPosition(point)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if self.handleTouch(touch: touch) {
            self.sendActions(for: .valueChanged)
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let _touch = touch else { return }
        _ = self.handleTouch(touch: _touch)
        self.sendActions(for: .valueChanged)
        self.isHighlighted = false
        self.setNeedsDisplay()
    }
    
    func valueDidChangeFrom(_ oldValue: CGFloat, newValue: CGFloat, animated: Bool) {
        let newAngle: CGFloat = self.angleForValue(newValue)
        if animated {
            let oldAngle: CGFloat = self.angleForValue(oldValue)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.duration = 0.2
            animation.values = [oldAngle * CGFloat.pi / 180.0,
                                (newAngle + oldAngle) / 2.0 * CGFloat.pi / 180.0,
                                newAngle * CGFloat.pi / 180]
            animation.keyTimes = [0.0, 0.5, 1.0]
            animation.timingFunctions = [.init(name: .easeIn), .init(name: .easeOut)]
            self.indicatorView.layer.add(animation, forKey: nil)
        }
        self.indicatorView.transform = CGAffineTransform(rotationAngle: newAngle * CGFloat.pi / 180.0)
    }
    
    override func draw(_ rect: CGRect) {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Set up Colors
        let strokeColor = UIColor(white: 0.06, alpha: 1.0)
        var gradientLightColor = UIColor(red: 0.101, green: 0.100, blue: 0.103, alpha: 1.000)
        var gradientDarkColor = UIColor(red: 0.237, green: 0.242, blue: 0.242, alpha: 1.000)

        if (self.isHighlighted) {
            gradientLightColor = gradientLightColor.darkerColor ?? gradientLightColor
            gradientDarkColor = gradientDarkColor.darkerColor ?? gradientDarkColor
        }

        let gradientColors = [gradientLightColor.cgColor, gradientDarkColor.cgColor]
//        CGFloat locations[] = {0, 1};
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors as CFArray, locations: [0, 1])
            //CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, locations);

        let insetRect = rect.insetBy(dx: 2, dy: 2)

        // Draw Bezel
        context.setFillColor(strokeColor.cgColor)
        context.fillEllipse(in: insetRect)

        let midX = insetRect.minX
        let midY = insetRect.minY

        // Draw Bezel Light Shadow Layer
        context.addArc(center: CGPoint(x: midX, y: midY), radius: insetRect.width / 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
//        CGContextAddArc(context, midX, midY, insetRect.width / 2, 0, CGFloat.pi * 2, 1);
        context.setShadow(offset: CGSize(width: 0.0, height: 0.5), blur: 2.0, color: UIColor.darkGray.cgColor)
//        CGContextSetShadowWithColor(context, CGSize(width: 0.0, height: 0.5), 2.0, UIColor.darkGray.cgColor)
        context.fillPath()

        // Add Clipping Region for Knob Background
        context.addArc(center: CGPoint(x: midX, y: midY), radius: insetRect.width - 6, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
//        CGContextAddArc(context, midX, midY, (CGRectGetWidth(insetRect) - 6) / 2, 0, M_PI * 2, 1);
        context.clip()

        let startPoint = CGPoint(x: midX, y: insetRect.maxY)
        let endPoint = CGPoint(x: midX, y: insetRect.minY)

        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//        gradient.re
//        CGGradientRelease(gradient!);
//        CGColorSpaceRelease(colorSpace);
    }
}

class ALGreenControlKnob: ALControlKnob {
    var indicatorLightColor: UIColor {
        return UIColor(red: 0.226, green: 1.000, blue: 0.226, alpha: 1.000)
    }
}

class ALOrangeControlKnob: ALControlKnob {
    var indicatorLightColor: UIColor {
        return UIColor(red: 1.000, green: 0.718, blue: 0.000, alpha: 1.000)
    }
}
