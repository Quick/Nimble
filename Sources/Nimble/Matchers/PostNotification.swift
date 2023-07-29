#if !os(WASI)

#if canImport(Foundation)
import Foundation

internal class NotificationCollector {
    private(set) var observedNotifications: [Notification]
    private(set) var observedNotificationDescriptions: [String]
    private let notificationCenter: NotificationCenter
    private let names: Set<Notification.Name>
    private var tokens: [NSObjectProtocol]

    required init(notificationCenter: NotificationCenter, names: Set<Notification.Name> = []) {
        self.notificationCenter = notificationCenter
        self.observedNotifications = []
        self.observedNotificationDescriptions = []
        self.names = names
        self.tokens = []
    }

    func startObserving() {
        func addObserver(forName name: Notification.Name?) -> NSObjectProtocol {
            return notificationCenter.addObserver(forName: name, object: nil, queue: nil) { [weak self] notification in
                // linux-swift gets confused by .append(n)
                self?.observedNotifications.append(notification)
                self?.observedNotificationDescriptions.append(stringify(notification))
            }
        }

        if names.isEmpty {
            tokens.append(addObserver(forName: nil))
        } else {
            names.forEach { name in
                tokens.append(addObserver(forName: name))
            }
        }
    }

    deinit {
        tokens.forEach { token in
            notificationCenter.removeObserver(token)
        }
    }
}

private final class OnlyOnceChecker: @unchecked Sendable {
    var hasRun = false
    let lock = NSRecursiveLock()

    func runOnlyOnce(_ closure: @Sendable () throws -> Void) rethrows {
        lock.lock()
        defer {
            lock.unlock()
        }
        if !hasRun {
            hasRun = true
            try closure()
        }
    }
}

private func _postNotifications<Out>(
    _ predicate: Predicate<[Notification]>,
    from center: NotificationCenter,
    names: Set<Notification.Name> = []
) -> Predicate<Out> {
    let collector = NotificationCollector(notificationCenter: center, names: names)
    collector.startObserving()
    let once = OnlyOnceChecker()

    return Predicate { actualExpression in
        guard Thread.isMainThread else {
            let message = ExpectationMessage
                .expectedTo("post notifications - but was called off the main thread.")
                .appended(details: "postNotifications and postDistributedNotifications attempted to run their predicate off the main thread. This is a bug in Nimble.")
            return PredicateResult(status: .fail, message: message)
        }

        let collectorNotificationsExpression = Expression(
            memoizedExpression: { _ in
                return collector.observedNotifications
            },
            location: actualExpression.location,
            withoutCaching: true
        )

        assert(Thread.isMainThread, "Only expecting closure to be evaluated on main thread.")
        try once.runOnlyOnce {
            _ = try actualExpression.evaluate()
        }

        let actualValue: String
        if collector.observedNotifications.isEmpty {
            actualValue = "no notifications"
        } else {
            actualValue = "<\(stringify(collector.observedNotificationDescriptions))>"
        }

        var result = try predicate.satisfies(collectorNotificationsExpression)
        result.message = result.message.replacedExpectation { message in
            return .expectedCustomValueTo(message.expectedMessage, actual: actualValue)
        }
        return result
    }
}

public func postNotifications<Out>(
    _ predicate: Predicate<[Notification]>,
    from center: NotificationCenter = .default
) -> Predicate<Out> {
    _postNotifications(predicate, from: center)
}

#if os(macOS)
public func postDistributedNotifications<Out>(
    _ predicate: Predicate<[Notification]>,
    from center: DistributedNotificationCenter = .default(),
    names: Set<Notification.Name>
) -> Predicate<Out> {
    _postNotifications(predicate, from: center, names: names)
}
#endif

#endif // #if canImport(Foundation)

#endif // #if !os(WASI)
