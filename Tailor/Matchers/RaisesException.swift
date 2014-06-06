import Foundation

struct _RaiseException<T>: MatcherWithFullMessage {
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

    func matches(actualExpression: () -> T) -> (pass: Bool, message: String)  {
        var exception: NSException?
        var capture = TSExceptionCapture(handler: ({ e in
            exception = e
        }), finally: nil)

        capture.tryBlock {
            actualExpression()
            return
        }
        return (validException(exception), messageForException(exception, to: "to"))
    }

    func doesNotMatch(actualExpression: () -> T) -> (pass: Bool, message: String)  {
        var exception: NSException?
        var capture = TSExceptionCapture(handler: ({ e in
            exception = e
            }), finally: nil)

        capture.tryBlock {
            actualExpression()
            return
        }
        return (!validException(exception), messageForException(exception, to: "to not"))
    }
}

func raiseException(#named: String, #reason: String?) -> _RaiseException<Void> {
    return _RaiseException(name: named, reason: reason, hasReason: true)
}

func raiseException(#named: String) -> _RaiseException<Void> {
    return _RaiseException(name: named, reason: nil, hasReason: false)
}
