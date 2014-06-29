import Foundation

func _raiseExceptionMatcher<T>(message: String, matches: (NSException?) -> Bool) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = message

        let (_, exception) = actualExpression.evaluateAndCaptureException()
        return matches(exception)
    }
}

func raiseException(#named: String, #reason: String?) -> MatcherFunc<Any> {
    return _raiseExceptionMatcher("raise exception named <\(named)> and reason <\(reason)>") {
        exception in return exception?.name == named && exception?.reason == reason
    }
}

func raiseException(#named: String) -> MatcherFunc<Any> {
    return _raiseExceptionMatcher("raise exception named <\(named)>") {
        exception in return exception?.name == named
    }
}

func raiseException() -> MatcherFunc<Any> {
    return _raiseExceptionMatcher("raise any exception") {
        exception in return exception != nil
    }
}
