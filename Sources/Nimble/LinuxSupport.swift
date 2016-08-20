import Foundation
import XCTest

#if os(Linux)
    extension Locale {
        convenience init(identifier: String) {
            self.init(localeIdentifier: identifier)
        }
    }

    extension NotificationCenter {
        internal class var `default`: NotificationCenter {
            return defaultCenter()
        }
        internal func addObserver(forName name: NSNotification.Name?, object obj: AnyObject?, queue: OperationQueue?, using block: @escaping (Notification) -> Swift.Void) -> NSObjectProtocol {
            return addObserverForName(name, object: obj, queue: queue, usingBlock: block)
        }
    }
#endif
