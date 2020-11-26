import Foundation

extension Calendar {
    // MARK: - Adding components to dates
    public func dateByAdding(years: Int, to date: Date) -> Date {
        var components = DateComponents()
        components.year = years
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateByAdding(months: Int, to date: Date) -> Date {
        var components = DateComponents()
        components.month = months
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateByAdding(weeks: Int, to date: Date) -> Date {
        var components = DateComponents()
        components.weekOfYear = weeks
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateByAdding(days: Int, to date: Date) -> Date {
        var components = DateComponents()
        components.day = days
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateByAdding(hours: Int, to date: Date) -> Date {
        var components = DateComponents()
        components.hour = hours
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateByAdding(minutes: Int, to date: Date) -> Date {
        var components = DateComponents()
        components.minute = minutes
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateByAdding(seconds: Int, to date: Date) -> Date {
        var components = DateComponents()
        components.second = seconds
        return self.date(byAdding: components, to: date)!
    }
    
    // MARK: - Subtracting components from dates
    public func dateBySubtracting(years: Int, from date: Date) -> Date {
        var components = DateComponents()
        components.year = -years
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateBySubtracting(months: Int, from date: Date) -> Date {
        var components = DateComponents()
        components.month = -months
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateBySubtracting(weeks: Int, from date: Date) -> Date {
        var components = DateComponents()
        components.weekOfYear = -weeks
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateBySubtracting(days: Int, from date: Date) -> Date {
        var components = DateComponents()
        components.day = -days
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateBySubtracting(hours: Int, from date: Date) -> Date {
        var components = DateComponents()
        components.hour = -hours
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateBySubtracting(minutes: Int, from date: Date) -> Date {
        var components = DateComponents()
        components.minute = -minutes
        return self.date(byAdding: components, to: date)!
    }
    
    public func dateBySubtracting(seconds: Int, from date: Date) -> Date {
        var components = DateComponents()
        components.second = -seconds
        return self.date(byAdding: components, to: date)!
    }
}
