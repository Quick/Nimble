import Foundation

struct _RaiseExceptionMatcher<T>: Matcher {
    let name: String?
    let reason: String?
    let hasReason: Bool

    func validException(exception: NSException?) -> Bool {
        return exception?.name == name &&
            (!hasReason || exception?.reason == reason)
    }

    func messageForException(exception: NSException?, to: String) -> String {
        if hasReason {
            return "expected \(to) raise exception named <\(name)> and reason <\(reason)>"
        } else {
            return "expected \(to) raise exception named <\(name)>"
        }
    }

    func matches(actualExpression: Expression<T>) -> (Bool, String)  {
        var exception: NSException?
        var capture = TSExceptionCapture(handler: ({ e in
            exception = e
        }), finally: nil)

        capture.tryBlock {
            actualExpression.evaluate()
            return
        }
        return (validException(exception), messageForException(exception, to: "to"))
    }

    func doesNotMatch(actualExpression: Expression<T>) -> (Bool, String)  {
        var exception: NSException?
        var capture = TSExceptionCapture(handler: ({ e in
            exception = e
            }), finally: nil)

        capture.tryBlock {
            actualExpression.evaluate()
            return
        }
        return (!validException(exception), messageForException(exception, to: "to not"))
    }
}

func raiseException(#named: String, #reason: String?) -> _RaiseExceptionMatcher<Void> {
    return _RaiseExceptionMatcher(name: named, reason: reason, hasReason: true)
}

func raiseException(#named: String) -> _RaiseExceptionMatcher<Void> {
    return _RaiseExceptionMatcher(name: named, reason: nil, hasReason: false)
}
