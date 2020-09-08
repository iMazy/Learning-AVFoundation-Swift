//
//  ALIndicatorLight.swift
//  AudioLooper
//
//  Created by Mazy on 2020/9/8.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class ALIndicatorLight: UIView {

    var lightColor: UIColor = UIColor.clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let midX: CGFloat = rect.midX
        let minY: CGFloat = rect.minY
        let width: CGFloat = rect.width * 0.15
        let height: CGFloat = rect.height * 0.15
        
        let indicatorRect: CGRect = CGRect(x: midX - (width / 2), y: minY + 15, width: width, height: height)

        guard let strokeColor = self.lightColor.darkerColor else { return }
        context.setStrokeColor(strokeColor.cgColor)
        context.setFillColor(self.lightColor.cgColor);

        guard let shadowColor = self.lightColor.lighterColor else { return }
        let shadowOffset = CGSize.zero
        let blurRadius: CGFloat = 5.0

        context.setShadow(offset: shadowOffset, blur: blurRadius, color: shadowColor.cgColor);

        context.addEllipse(in: indicatorRect)
        context.drawPath(using: .fillStroke)
    }
}
