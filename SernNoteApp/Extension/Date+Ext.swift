//
//  Date+Ext.swift
//  SernNoteApp
//
//  Created by sonnd on 10/3/25.
//

import Foundation


extension Date {
    var day: Int {
        var calendar = Calendar.current
        calendar.timeZone = .current
        return calendar.component(.day, from: self)
    }
    
    var month: Int {
        var calendar = Calendar.current
        calendar.timeZone = .current
        return calendar.component(.month, from: self)
    }
    
    var year: Int {
        var calendar = Calendar.current
        calendar.timeZone = .current
        return calendar.component(.year, from: self)
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self)))!
    }
}

extension Formatter {
    static let monthMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL"
        return formatter
    }()
    
    static let hour24: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }()
    
    static let minute0x: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
}
extension Date {
    var monthMedium: String  { return Formatter.monthMedium.string(from: self) }
    var hour24:  String      { return Formatter.hour24.string(from: self) }
    var minute0x: String     { return Formatter.minute0x.string(from: self) }
}
