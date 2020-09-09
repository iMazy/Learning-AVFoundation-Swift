//
//  VMLevelPair.swift
//  VoiceMemo
//
//  Created by Mazy on 2020/9/9.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class VMLevelPair: NSObject {

    var level: Float = 0
    var peakLevel: Float = 0
    
    convenience init(with level: Float, peakLevel: Float) {
        self.init()
        self.level = level
        self.peakLevel = peakLevel
    }
}
