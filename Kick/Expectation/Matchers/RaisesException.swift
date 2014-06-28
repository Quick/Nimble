import Foundation

func _raisedExceptionForExpression<T>(expr: Expression<T>) -> NSException? {
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

func raiseException(#named: String, #reason: String?) -> FuncMatcherWrapper<Void> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = "raise exception named <\(named)> and reason <\(reason)>"

        let exception = _raisedExceptionForExpression(actualExpression)
        return exception?.name == named && exception?.reason == reason
    }
}

func raiseException(#named: String) -> FuncMatcherWrapper<Void> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = "raise exception named <\(named)>"

        let exception = _raisedExceptionForExpression(actualExpression)
        return exception?.name == named
    }
}
