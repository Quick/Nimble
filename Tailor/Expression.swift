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
    let expression: () -> T
    let location: SourceLocation
    let allowCaching: Bool
    var cache: T?

    init(expression: () -> T, location: SourceLocation) {
        self.expression = expression
        self._expression = _memoizedClosure(expression)
        self.location = location
        self.allowCaching = false
    }

    init(expression: () -> T, location: SourceLocation, allowCaching: Bool) {
        self.expression = expression
        self._expression = ({ allowCaching in expression() })
        self.location = location
        self.allowCaching = allowCaching
    }

    func evaluate(invalidateCache: Bool = false) -> T {
        return self._expression(invalidateCache: invalidateCache && allowCaching)
    }

    func withoutCaching() -> Expression<T> {
        return Expression(expression: self.expression, location: location, allowCaching: false)
    }
}
