#if canImport(Foundation)
import Foundation

internal class NotificationCollector {
    private(set) var observedNotifications: [Notification]
    private let notificationCenter: NotificationCenter
    private let names: Set<Notification.Name>?
    private var tokens: [NSObjectProtocol]

    required init(notificationCenter: NotificationCenter, names: Set<Notification.Name>?) {
        self.notificationCenter = notificationCenter
        self.observedNotifications = []
        self.names = names?.isEmpty == true ? nil : names
        self.tokens = []
    }

    func startObserving() {
        if let names = self.names {
            self.tokens.append(contentsOf: names.map { name in
                self.notificationCenter.addObserver(forName: name, object: nil, queue: nil) { [weak self] notification in
                    // linux-swift gets confused by .append(n)
                    self?.observedNotifications.append(notification)
                }
            })
        } else {
            // swiftlint:disable:next line_length
            self.tokens.append(self.notificationCenter.addObserver(forName: nil, object: nil, queue: nil) { [weak self] notification in
                // linux-swift gets confused by .append(n)
                self?.observedNotifications.append(notification)
            })
        }
    }

    deinit {
        self.tokens.forEach { token in
            self.notificationCenter.removeObserver(token)
        }
    }
}

private let mainThread = pthread_self()

public func postNotifications(
    _ predicate: Predicate<[Notification]>,
    fromNotificationCenter center: NotificationCenter = .default
) -> Predicate<Any> {
    _postNotifications(predicate, fromNotificationCenter: center, names: nil)
}

private func _postNotifications(
    _ predicate: Predicate<[Notification]>,
    fromNotificationCenter center: NotificationCenter,
    names: Set<Notification.Name>?
) -> Predicate<Any> {
    _ = mainThread // Force lazy-loading of this value
    let collector = NotificationCollector(notificationCenter: center, names: names)
    collector.startObserving()
    var once: Bool = false

    return Predicate { actualExpression in
        let collectorNotificationsExpression = Expression(
            memoizedExpression: { _ in
                return collector.observedNotifications
            },
            location: actualExpression.location,
            withoutCaching: true
        )

        assert(pthread_equal(mainThread, pthread_self()) != 0, "Only expecting closure to be evaluated on main thread.")
        if !once {
            once = true
            _ = try actualExpression.evaluate()
        }

        let actualValue: String
        if collector.observedNotifications.isEmpty {
            actualValue = "no notifications"
        } else {
            actualValue = "<\(stringify(collector.observedNotifications))>"
        }

        var result = try predicate.satisfies(collectorNotificationsExpression)
        result.message = result.message.replacedExpectation { message in
            return .expectedCustomValueTo(message.expectedMessage, actual: actualValue)
        }
        return result
    }
}

#if os(OSX)
public func postDistributedNotifications(
    _ predicate: Predicate<[Notification]>,
    fromNotificationCenter center: DistributedNotificationCenter = .default(),
    names: Set<Notification.Name>
) -> Predicate<Any> {
    _postNotifications(predicate, fromNotificationCenter: center, names: names)
}
#endif

@available(*, deprecated, message: "Use Predicate instead")
public func postNotifications<T>(
    _ notificationsMatcher: T,
    fromNotificationCenter center: NotificationCenter = .default)
    -> Predicate<Any>
    where T: Matcher, T.ValueType == [Notification] {
    _ = mainThread // Force lazy-loading of this value
        let collector = NotificationCollector(notificationCenter: center, names: nil)
    collector.startObserving()
    var once: Bool = false

    return Predicate { actualExpression in
        let collectorNotificationsExpression = Expression(memoizedExpression: { _ in
            return collector.observedNotifications
            }, location: actualExpression.location, withoutCaching: true)

        assert(pthread_equal(mainThread, pthread_self()) != 0, "Only expecting closure to be evaluated on main thread.")
        if !once {
            once = true
            _ = try actualExpression.evaluate()
        }

        let failureMessage = FailureMessage()
        let match = try notificationsMatcher.matches(collectorNotificationsExpression, failureMessage: failureMessage)
        if collector.observedNotifications.isEmpty {
            failureMessage.actualValue = "no notifications"
        } else {
            failureMessage.actualValue = "<\(stringify(collector.observedNotifications))>"
        }
        return PredicateResult(bool: match, message: failureMessage.toExpectationMessage())
    }
}
#endif
