import Foundation

// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
func _memoizedClosure<T>(closure: () -> T) -> () -> T {
    var cache: T?
    return ({
        if (!cache) {
            cache = closure()
        }
        return cache!
        })
}

struct Expression<T> {
    let _expression: () -> T
    let _memoizedExpression: () -> T
    let location: SourceLocation

    init(expression: () -> T, location: SourceLocation) {
        self._expression = expression
        self._memoizedExpression = _memoizedClosure(expression)
        self.location = location
    }

    func evaluateIfNeeded() -> T {
        return self._memoizedExpression()
    }

    func evaluate() -> T {
        return self._expression()
    }
}
