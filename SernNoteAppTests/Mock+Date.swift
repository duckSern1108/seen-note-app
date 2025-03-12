//
//  MockDate.swift
//  SernNoteAppTests
//
//  Created by sonnd on 12/3/25.
//

import Foundation


extension Date {
    static func mockDateFrom(day: Int = 1, month: Int, year: Int) -> Date {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = Calendar.current.timeZone
        return Calendar.current.date(from: dateComponents)!
    }
   
}
