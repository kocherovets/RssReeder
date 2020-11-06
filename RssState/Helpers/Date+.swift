import Foundation

extension Date {
    func toShortTimeString() -> String {
        // Get Short Time String
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: self)
        
        // Return Short Time String
        return timeString
    }
    
    func toSimpleString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func removeTime() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day, .month, .year], from: self)
        return calendar.date(from: components)!
    }
    
    func removeSeconds() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.minute, .hour, .day, .month, .year], from: self)
        return calendar.date(from: components)!
    }
    
    func extractTime() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute], from: self)
        return calendar.date(from: components)!
    }
    
    
    // getters
    
    var hour: Int {
        // Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        
        // Return Hour
        return hour!
    }
    
    var minute: Int {
        // Get Minute
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        
        // Return Minute
        return minute!
    }
    
    var dayOfWeek: Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.weekday, from: self)
        return components.weekday!
    }
    
    var day: Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        return components.day!
    }
    
    var weekOfYear: Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.weekOfYear, from: self)
        return components.weekOfYear!
    }
    
    var month: Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.month, from: self)
        return components.month! // 1...
    }
    
    var year: Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.year, from: self)
        return components.year!
    }
    
    // setters
    
    func set(minutes value: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.minute, .hour, .day, .month, .year], from: self)
        components.minute = value
        return calendar.date(from: components)!
    }
    
    func set(hours value: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.minute, .hour, .day, .month, .year], from: self)
        components.hour = value
        return calendar.date(from: components)!
    }
    
    func set(day value: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.minute, .hour, .day, .month, .year], from: self)
        components.day = value
        return calendar.date(from: components)!
    }
    
    func set(month value: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.minute, .hour, .day, .month, .year], from: self)
        components.month = value
        return calendar.date(from: components)!
    }
    
    func set(year value: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.minute, .hour, .day, .month, .year], from: self)
        components.year = value
        return calendar.date(from: components)!
    }
    
    func set(weekDay value: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.minute, .hour, .weekday, .weekOfYear, .year], from: self)
        components.weekday = value
        return calendar.date(from: components)!
    }
    
    func set(weekOfYear value: Int) -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.minute, .hour, .weekday, .weekOfYear, .year], from: self)
        components.weekOfYear = value
        return calendar.date(from: components)!
    }
    
    // MARK: - Adding components to date
    
    public func adding(years: Int) -> Date {
        return Calendar.current.dateByAdding(years: years, to: self)
    }
    
    public func adding(months: Int) -> Date {
        return Calendar.current.dateByAdding(months: months, to: self)
    }
    
    public func adding(weeks: Int) -> Date {
        return Calendar.current.dateByAdding(weeks: weeks, to: self)
    }
    
    public func adding(days: Int) -> Date {
        return Calendar.current.dateByAdding(days: days, to: self)
    }
    
    public func adding(hours: Int) -> Date {
        return Calendar.current.dateByAdding(hours: hours, to: self)
    }
    
    public func adding(minutes: Int) -> Date {
        return Calendar.current.dateByAdding(minutes: minutes, to: self)
    }
    
    public func adding(seconds: Int) -> Date {
        return Calendar.current.dateByAdding(seconds: seconds, to: self)
    }
    
    // MARK: - Subtracting components from date
    
    public func subtracting(years: Int) -> Date {
        return Calendar.current.dateBySubtracting(years: years, from: self)
    }
    
    public func subtracting(months: Int) -> Date {
        return Calendar.current.dateBySubtracting(months: months, from: self)
    }
    
    public func subtracting(weeks: Int) -> Date {
        return Calendar.current.dateBySubtracting(weeks: weeks, from: self)
    }
    
    public func subtracting(days: Int) -> Date {
        return Calendar.current.dateBySubtracting(days: days, from: self)
    }
    
    public func subtracting(hours: Int) -> Date {
        return Calendar.current.dateBySubtracting(hours: hours, from: self)
    }
    
    public func subtracting(minutes: Int) -> Date {
        return Calendar.current.dateBySubtracting(minutes: minutes, from: self)
    }
    
    public func subtracting(seconds: Int) -> Date {
        return Calendar.current.dateBySubtracting(seconds: seconds, from: self)
    }
    
}
