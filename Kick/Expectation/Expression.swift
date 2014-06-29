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

    func evaluateAndCaptureException() -> (T?, NSException?) {
        var exception: NSException?
        var result: T?
        var capture = KICExceptionCapture(handler: ({ e in
            exception = e
        }), finally: nil)

        capture.tryBlock {
            result = self.evaluate()
            return
        }
        return (result, exception)
    }

    func withoutCaching() -> Expression<T> {
        return Expression(memoizedExpression: self._expression, location: location, allowCaching: false)
    }
}
