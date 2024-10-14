import Foundation

final class LockedContainer<T: Sendable>: @unchecked Sendable {
    private let lock = NSRecursiveLock()
    private var _value: T

    var value: T {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    init(_ value: T) {
        _value = value
    }

    init(_ closure: () -> T) {
        _value = closure()
    }

    func operate(_ closure: (T) -> T) {
        lock.lock()
        defer { lock.unlock() }
        _value = closure(_value)
    }

    func set(_ newValue: T) {
        lock.lock()
        defer { lock.unlock() }
        _value = newValue
    }
}
