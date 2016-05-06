import Foundation

#if os(Linux)
    extension NSDate {
        func addingTimeInterval(ti: NSTimeInterval) -> NSDate {
            return dateByAddingTimeInterval(ti)
        }

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

    extension NSNumber {
        internal convenience init(value: Int) {
            self.init(integer:value)
        }
        internal convenience init(value: Double) {
            self.init(double:value)
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

    extension String {
        func data(using encoding: NSStringEncoding, allowLossyConversion: Bool = false) -> NSData? {
            return dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion)
        }
    }
#endif
