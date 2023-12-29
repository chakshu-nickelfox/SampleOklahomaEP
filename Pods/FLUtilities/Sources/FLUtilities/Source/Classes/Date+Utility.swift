//
//  Date+Utility.swift
//  FLUtilities
//
//  Created by Ravindra Soni on 18/12/16.
//  Copyright © 2016 Nickelfox. All rights reserved.
//

import Foundation

let calendar = Calendar.current

public extension Date {
    
    var isToday: Bool {
        return calendar.compare(self, to: Date(), toGranularity: .day) == .orderedSame
    }
    
    var isPastDate: Bool {
        return calendar.compare(self, to: Date(), toGranularity: .day) == .orderedAscending
    }
    
    func add(seconds: Int) -> Date {
        return calendar.date(byAdding: .second, value: seconds,to: self) ?? self
    }
    
    func subtract(seconds: Int) -> Date {
        return self.add(seconds: -seconds)
    }
    
    func add(minutes: Int) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    func subtract(minutes: Int) -> Date {
        return self.add(minutes: -minutes)
    }
    
    func add(hours: Int) -> Date {
        return calendar.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    func subtract(hours: Int) -> Date {
        return self.add(hours: -hours)
    }
    
    func add(days: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days
        let newDate = calendar.date(byAdding: dateComponents, to: self)
        return newDate ?? self
    }
    
    func subtract(days: Int) -> Date {
        return self.add(days: -days)
    }
    
    func add(months: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = months
        let newDate = calendar.date(byAdding: dateComponents, to: self)
        return newDate ?? self
    }
    
    func subtract(months: Int) -> Date {
        return self.add(months: -months)
    }
    
    func add(years: Int) -> Date {
        return calendar.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    func subtract(years: Int) -> Date {
        return self.add(years: -years)
    }
    
    // Returns months passed from given date till today
    func monthsFrom(date: Date) -> Int {
        return calendar.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    func daysFrom(date: Date) -> Int {
        return calendar.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    //Monday
    func dayOfWeekFull() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    //Mon
    func dayOfWeekShort() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    func monthStringFull() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    
    func monthStringShort() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    
}
