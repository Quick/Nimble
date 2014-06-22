import Foundation

// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
func _memoizedClosure<T>(closure: () -> T) -> (invalidateCache: Bool) -> T {
    var cache: T?
    return ({ invalidateCache in
        if (invalidateCache || !cache) {
            cache = closure()
        }
        return cache!
    })
}

struct Expression<T> {
    let _expression: (invalidateCache: Bool) -> T
    let location: SourceLocation
    let allowCaching: Bool
    var cache: T?

    init(expression: () -> T, location: SourceLocation) {
        self._expression = _memoizedClosure(expression)
        self.location = location
        self.allowCaching = false
    }

    init(memoizedExpression: (invalidateCache: Bool) -> T, location: SourceLocation, allowCaching: Bool) {
        self._expression = memoizedExpression
        self.location = location
        self.allowCaching = allowCaching
    }

    func evaluate() -> T {
        return self._expression(invalidateCache: !allowCaching)
    }

    func withoutCaching() -> Expression<T> {
        return Expression(memoizedExpression: self._expression, location: location, allowCaching: false)
    }
}
