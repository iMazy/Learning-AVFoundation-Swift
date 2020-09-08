//
//  ALPlayButton.swift
//  AudioLooper
//
//  Created by Mazy on 2020/9/8.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class ALPlayButton: UIButton {

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
        setNeedsDisplay()
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
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors as CFArray, locations: [0, 1])

        var insetRect = rect.insetBy(dx: 2.0, dy: 2.0)

        // Draw Bezel
        context.setFillColor(strokeColor.cgColor)
        
        let bezelPath = UIBezierPath(roundedRect: insetRect, cornerRadius: 6.0)
        context.addPath(bezelPath.cgPath)
        context.setShadow(offset: CGSize(width: 0.0, height: 0.5), blur: 2.0, color: UIColor.darkGray.cgColor)
        context.drawPath(using: .fill)
//        CGContextDrawPath(context, kCGPathFill);

        context.saveGState()
        
//        CGContextSaveGState(context);
        // Add Clipping Region for Knob Background
        insetRect = insetRect.insetBy(dx: 3.0, dy: 3.0) //CGRectInset(insetRect, 3.0, 3.0)
        
        let buttonPath = UIBezierPath(roundedRect: insetRect, cornerRadius: 4.0)
        context.addPath(buttonPath.cgPath)
        context.clip()

        let midX = insetRect.midX

        let startPoint = CGPoint(x: midX, y: insetRect.maxY)
        let endPoint = CGPoint(x: midX, y: insetRect.minY)

        // Draw Button Gradient Background
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
//        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);

        // Cleanup
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
//        CGContextRestoreGState(context);

        let fillColor = UIColor(white: 0.9, alpha: 1.0)
        context.setFillColor(fillColor.cgColor)
        context.setStrokeColor(fillColor.darkerColor!.cgColor)

        let iconDim: CGFloat = 24.0
        // Draw Play Button
        if (!self.isSelected) {
            context.saveGState()
            context.ctm.translatedBy(x: rect.midX - (iconDim - 3) / 2, y: rect.midY - iconDim / 2)
            context.move(to: CGPoint.zero)
            context.addLine(to: CGPoint(x: 0, y: iconDim))
            context.addLine(to: CGPoint(x: iconDim, y: iconDim / 2))
            context.closePath()
            context.drawPath(using: .fill)
            
//            CGContextRestoreGState(context);
        }
        // Draw Stop Button
        else {
            context.saveGState()
            
            let tx: CGFloat = (rect.width - iconDim) / 2
            let ty: CGFloat = (rect.height -  iconDim) / 2
            context.ctm.translatedBy(x: tx, y: ty)
            
            let stopRect = CGRect(x: 0, y: 0, width: iconDim, height: iconDim)
            
            let stopPath = UIBezierPath(roundedRect: stopRect, cornerRadius: 2.0)
            context.addPath(stopPath.cgPath)
            context.drawPath(using: .fill)
//            CGContextAddPath(context, stopPath.CGPath);
//            CGContextDrawPath(context, kCGPathFill);
            context.restoreGState()
//            CGContextRestoreGState(context);
        }
    }
}
