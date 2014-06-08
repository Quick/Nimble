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
    let expression: () -> T
    let memoizedExpression: () -> T

    init(closure: () -> T) {
        self.expression = closure
        self.memoizedExpression = _memoizedClosure(closure)
    }

    func evaluateIfNeeded() -> T {
        return self.memoizedExpression()
    }

    func evaluate() -> T {
        return self.expression()
    }
}
