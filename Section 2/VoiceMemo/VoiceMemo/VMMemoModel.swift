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

    convenience init(title: String, url: URL) {
        self.init()
        self.title = title
        self.url = url
        let lastPathComponent = url.lastPathComponent.replacingOccurrences(of: ".m4a", with: "")
        let infos = lastPathComponent.components(separatedBy: "-")
        guard let time = infos.last else { return }
        let formatter = DateFormatter()
          formatter.dateFormat = "yyyyMMddHHmmss"
          if let date = formatter.date(from: time) {
              self.dateString = self.dateStringWithDate(date)
              self.timeString = self.timeStringWithDate(date)
          }
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
