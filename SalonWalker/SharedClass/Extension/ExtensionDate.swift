//
//  ExtensionDate.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/8.
//  Copyright © 2018年 skywind. All rights reserved.
//

import Foundation

extension Date {
    func transferToString(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
    
    func getDayOfWeek() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let weekDay = calendar.component(.weekday, from: self)
        // weekDay 1 -> 星期日, weekDay 2 -> 星期一, etc
        // 為了配合extension Int中的transferToWeekString function(星期日為0,星期一為1),故減1
        return weekDay - 1
    }
    
    static func from(year: Int, month: Int, day: Int) -> Date {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        let date = gregorianCalendar.date(from: dateComponents)!
        return date
    }
    
    static func from(string: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: string)!
        return date
    }
    
    static func timeZoneString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ZZZZ"
        return formatter.string(from: Date())
    }
}
