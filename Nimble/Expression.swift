import Foundation

// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
func _memoizedClosure<T>(closure: () -> T) -> (Bool) -> T {
    var cache: T?
    return ({ withoutCaching in
        if (withoutCaching || !cache) {
            cache = closure()
        }
        return cache!
    })
}

struct Expression<T> {
    let _expression: (Bool) -> T
    let location: SourceLocation
    let _withoutCaching: Bool
    var cache: T?

    init(expression: () -> T, location: SourceLocation) {
        self._expression = _memoizedClosure(expression)
        self.location = location
        self._withoutCaching = false
    }

    init(memoizedExpression: (Bool) -> T, location: SourceLocation, withoutCaching: Bool) {
        self._expression = memoizedExpression
        self.location = location
        self._withoutCaching = withoutCaching
    }

    func evaluate() -> T {
        return self._expression(_withoutCaching)
    }

    func withoutCaching() -> Expression<T> {
        return Expression(memoizedExpression: self._expression, location: location, withoutCaching: true)
    }
}
