//
//  Date+GMDKit.swift
//  Pods
//
//  Created by Gabriel Morales on 3/8/17.
//
//

import Foundation

extension Date {
    
    static let formatter = DateFormatter()
    
    static func yesterday() -> Date {
        
        return Date().dateWith(daysToAdd: -1, monthsToAdd: 0)
    }
    
    static func today() -> Date {
        
        return Date().dateWith(daysToAdd: 0, monthsToAdd: 0).dateByZeroOutTimeComponents()
    }
    
    static func tomorrow() -> Date {
        
        return Date().dateWith(daysToAdd: 1, monthsToAdd: 0)
    }
    
    public func dateByAddingDays(days: Int) -> Date {
        return self.days(days: days)
    }
    
    public func dateBySubstractingDays(days: Int) -> Date {
        return self.days(days: -days)
    }
    
    public func days(days:Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
    
    public func dateWith(daysToAdd:Int, monthsToAdd:Int) -> Date{
        let gregorian = NSCalendar.current
        var components = DateComponents()
        components.day = daysToAdd
        components.month = monthsToAdd
        
        return gregorian.date(byAdding: components, to: self)!
    }
    
    public func dateByZeroOutTimeComponents() -> Date{
        
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents(Set([.year, .month, .day]), from: self)
        self.zeroOutTimeComponents(&components)
        return calendar.date(from: components)!
    }
    
    public func zeroOutTimeComponents( _ components:inout DateComponents) {
        components.hour = 0
        components.minute = 0
        components.second = 0
    }
    
    public func timelessCompare(date:Date) -> ComparisonResult? {
        
        let date1 = self.dateByZeroOutTimeComponents()
        let date2 = date.dateByZeroOutTimeComponents()
        return date1.compare(date2)
    }
    
    public func isSameDayAs(_ date:Date) -> Bool {
        
        Date.formatter.dateFormat = "MM/dd/yyyy"
        Date.formatter.timeZone = TimeZone(identifier: "America/Chicago")
        
        let selfDateString = Date.formatter.string(from: self)
        let otherDateString = Date.formatter.string(from: date)
        
        return selfDateString == otherDateString
        
    }
    
}
