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
    
    /// 通过url创建模型
    /// - Parameters:
    ///   - title: 标题
    ///   - url: url 地址 包含名称+时间
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
    
    /// 删除当前模型中的url
    /// - Returns: 结果
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

    /// 获取年月日
    /// - Parameter date: 日期
    /// - Returns: 年月日
    func dateStringWithDate(_ date: Date) -> String {
        let formatter = formatterWithFormat("MMddyyyy")
        return formatter.string(from: date)
    }
    
    /// 获取时分秒
    /// - Parameter date: 日期
    /// - Returns: 时分秒
    func timeStringWithDate(_ date: Date) -> String {
        let formatter = formatterWithFormat("HHmmss")
        return formatter.string(from: date)
    }
    
    /// 获取格式
    /// - Parameter template: 时间样式
    /// - Returns: DateFormatter
    func formatterWithFormat(_ template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let format = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        formatter.dateFormat = format
        return formatter
    }
}
