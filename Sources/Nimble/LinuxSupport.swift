import Foundation
import XCTest

#if os(Linux)
    public typealias ComparisonResult = NSComparisonResult
    public typealias Date = NSDate
    public typealias DateFormatter = NSDateFormatter
    public typealias Locale = NSLocale
    public typealias NotificationCenter = NSNotificationCenter
    public typealias Thread = NSThread

    extension NSMutableArray {
        internal func add(_ anObject: AnyObject) {
            addObject(anObject)
        }
        internal func componentsJoined(by separator: String) -> String {
            return componentsJoinedByString(separator)
        }
    }

    extension NSNotificationCenter {
        internal class func `default`() -> NSNotificationCenter {
            return defaultCenter()
        }
        internal func addObserver(forName name: String?, object obj: AnyObject?, queue: NSOperationQueue?, using block: (NSNotification) -> Swift.Void) -> NSObjectProtocol {
            return addObserverForName(name, object: obj, queue: queue, usingBlock: block)
        }
    }

    extension NSThread {
        internal class func current() -> NSThread {
            return currentThread()
        }
    }
#endif
