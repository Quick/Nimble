import Foundation

#if os(Linux)
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

    extension NSThread {
        @nonobjc internal class func sleep(forTimeInterval ti: NSTimeInterval) {
            return sleepForTimeInterval(ti)
        }
    }
#endif
