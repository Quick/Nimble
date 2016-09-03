import Foundation

#if os(Linux)
    extension NSNotification.Name {
        init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
    }

    extension Date {
        public func addingTimeInterval(_ timeInterval: TimeInterval) -> Date {
            return self + timeInterval
        }
    }

    extension NotificationCenter {
        func post(_ notification: Notification) {
            postNotification(notification)
        }
    }
#endif
