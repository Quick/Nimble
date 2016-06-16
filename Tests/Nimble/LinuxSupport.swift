import Foundation

#if os(Linux)
    public typealias ComparisonResult = NSComparisonResult
    public typealias Date = NSDate
    public typealias DateFormatter = NSDateFormatter
    public typealias Locale = NSLocale
    public typealias Notification = NSNotification
    public typealias NotificationCenter = NSNotificationCenter
    public typealias Thread = NSThread

    extension NSDate {
        convenience init(timeInterval secsToBeAdded: NSTimeInterval, since date: NSDate) {
            self.init(timeInterval: secsToBeAdded, sinceDate: date)
        }
    }

    extension NSDateFormatter {
        func date(from string: String) -> NSDate? {
            return dateFromString(string)
        }
    }

    extension NSNotification {
        typealias Name = String
    }

    extension NSNotification.Name {
        var rawValue: String {
            return self
        }
    }

    extension NSNotificationCenter {
        func post(_ notification: NSNotification) {
            postNotification(notification)
        }
    }

    extension NSRunLoop {
        @available(OSX 10.5, *)
        internal class func main() -> NSRunLoop {
            return mainRunLoop()
        }
        
        internal func run(until limitDate: NSDate) {
            return runUntilDate(limitDate)
        }
    }

    extension NSStringEncoding {
        static var utf8: UInt = NSUTF8StringEncoding
    }

    extension NSThread {
        @nonobjc internal class func sleep(forTimeInterval ti: NSTimeInterval) {
            return sleepForTimeInterval(ti)
        }
    }
#endif
