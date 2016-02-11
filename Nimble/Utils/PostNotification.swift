import Foundation

internal class NotificationCollector {
    private(set) var observedNotifications: [NSNotification]
    private let notificationCenter: NSNotificationCenter
    private var token: AnyObject?

    required init(notificationCenter: NSNotificationCenter) {
        self.notificationCenter = notificationCenter
        self.observedNotifications = []
    }

    func startObserving() {
        self.token = self.notificationCenter.addObserverForName(nil, object: nil, queue: nil) { [weak self] n -> Void in
            self?.observedNotifications.append(n)
        }
    }

    deinit {
        if let token = self.token {
            self.notificationCenter.removeObserver(token)
        }
    }
}

public func postNotifications<T where T: Matcher, T.ValueType == [NSNotification]>(
                notificationsMatcher: T,
                fromNotificationCenter center: NSNotificationCenter = NSNotificationCenter.defaultCenter())
                -> MatcherFunc<Any> {
    let collector = NotificationCollector(notificationCenter: center)
    collector.startObserving()
    var once: Bool = false
    return MatcherFunc { actualExpression, failureMessage in
        let collectorNotificationsExpression = Expression(memoizedExpression: { _ in
            return collector.observedNotifications
        }, location: actualExpression.location, withoutCaching: true)

        assert(NSThread.isMainThread(), "Only expecting closure to be evaluated on main thread.")
        if !once {
            once = true
            try actualExpression.evaluate()
        }

        let match = try notificationsMatcher.matches(collectorNotificationsExpression, failureMessage: failureMessage)
        if collector.observedNotifications.isEmpty {
            failureMessage.actualValue = "no notifications"
        } else {
            failureMessage.actualValue = "<\(stringify(collector.observedNotifications))>"
        }
        return match
    }
}
