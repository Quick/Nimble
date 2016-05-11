import Foundation
import XCTest

#if os(Linux)
    extension NSComparisonResult {
        internal static var orderedAscending: NSComparisonResult { return .OrderedAscending }
        internal static var orderedSame: NSComparisonResult { return .OrderedSame }
        internal static var orderedDescending: NSComparisonResult { return .OrderedDescending }
    }

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

    extension NSRunLoop {
        internal class func current() -> NSRunLoop {
            return currentRunLoop()
        }
        internal func run(mode: String, before limitDate: NSDate) -> Bool {
            return runMode(mode, beforeDate: limitDate)
        }
    }

    extension NSThread {
        internal class func current() -> NSThread {
            return currentThread()
        }
    }
#endif
