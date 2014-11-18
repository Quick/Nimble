import Foundation

// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
internal func memoizedClosure<T>(closure: () -> T) -> (Bool) -> T {
    var cache: T?
    return ({ withoutCaching in
        if (withoutCaching || cache == nil) {
            cache = closure()
        }
        return cache!
    })
}

public struct Expression<T> {
    internal let _expression: (Bool) -> T?
    internal let _withoutCaching: Bool
    public let location: SourceLocation
    public var cache: T?

    public init(expression: () -> T?, location: SourceLocation) {
        self._expression = memoizedClosure(expression)
        self.location = location
        self._withoutCaching = false
    }

    public init(memoizedExpression: (Bool) -> T?, location: SourceLocation, withoutCaching: Bool) {
        self._expression = memoizedExpression
        self.location = location
        self._withoutCaching = withoutCaching
    }

    public func cast<U>(block: (T?) -> U?) -> Expression<U> {
        return Expression<U>(expression: ({ block(self.evaluate()) }), location: self.location)
    }

    public func evaluate() -> T? {
        return self._expression(_withoutCaching)
    }

    public func withoutCaching() -> Expression<T> {
        return Expression(memoizedExpression: self._expression, location: location, withoutCaching: true)
    }
}
