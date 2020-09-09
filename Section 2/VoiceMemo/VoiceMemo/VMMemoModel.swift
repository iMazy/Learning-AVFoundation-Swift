//
//  VMMemoModel.swift
//  VoiceMemo
//
//  Created by Mazy on 2020/9/9.
//  Copyright © 2020 mazy. All rights reserved.
//

import UIKit

class VMMemoModel: NSObject {
    
    var title: String = ""
    var url: URL?
    var dateString: String = ""
    var timeString: String = ""

//    static func memoWithTitle(_ title: String, url: URL) {
//        return self.init()
//    }
    convenience init(title: String, url: URL) {
        self.init()
        self.title = title
        self.url = url
        
    }
    
    func deleteMemo() -> Bool {
        guard let url = self.url else {
            return false
        }
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}

extension VMMemoModel {
    
    func dateStringWithDate(_ date: Date) -> String {
        let formatter = formatterWithFormat("MMddyyyy")
        return formatter.string(from: date)
    }
    
    func timeStringWithDate(_ date: Date) -> String {
        let formatter = formatterWithFormat("HHmmss")
        return formatter.string(from: date)
    }
    
    func formatterWithFormat(_ template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let format = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        formatter.dateFormat = format
        return formatter
    }
}
