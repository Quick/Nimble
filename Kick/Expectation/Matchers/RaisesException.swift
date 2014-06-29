import Foundation

func _captureExceptionInExpression<T>(expr: Expression<T>) -> NSException? {
    var exception: NSException?
    var capture = KICExceptionCapture(handler: ({ e in
        exception = e
        }), finally: nil)

    capture.tryBlock {
        expr.evaluate()
        return
    }
    return exception
}

func raiseException(#named: String, #reason: String?) -> MatcherFunc<Void> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = "raise exception named <\(named)> and reason <\(reason)>"

        let exception = _captureExceptionInExpression(actualExpression)
        return exception?.name == named && exception?.reason == reason
    }
}

func raiseException(#named: String) -> MatcherFunc<Void> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = "raise exception named <\(named)>"

        let exception = _captureExceptionInExpression(actualExpression)
        return exception?.name == named
    }
}

func raiseException() -> MatcherFunc<Void> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = "raise exception"

        if _captureExceptionInExpression(actualExpression) {
            return true
        }
        return false
    }
}
