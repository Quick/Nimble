import Foundation

func _raiseExceptionMatcher<T>(message: String, matches: (NSException?) -> Bool) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = message

        let (_, exception) = actualExpression.evaluateAndCaptureException()
        return matches(exception)
    }
}

func raiseException(#named: String, #reason: String?) -> MatcherFunc<Any?> {
    return _raiseExceptionMatcher("raise exception named <\(named)> and reason <\(reason)>") {
        exception in return exception?.name == named && exception?.reason == reason
    }
}

func raiseException(#named: String) -> MatcherFunc<Any?> {
    return _raiseExceptionMatcher("raise exception named <\(named)>") {
        exception in return exception?.name == named
    }
}

func raiseException() -> MatcherFunc<Any?> {
    return _raiseExceptionMatcher("raise any exception") {
        exception in return exception != nil
    }
}

@objc class KICObjCRaiseExceptionMatcher : KICMatcher {
    var _name: String?
    var _reason: String?
    init(name: String?, reason: String?) {
        _name = name
        _reason = reason
    }

    func matches(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let block: () -> Any? = ({ actualBlock(); return nil })
        let expr = Expression(expression: block, location: location)
        if _name && _reason {
            return raiseException(named: _name!, reason: _reason).matches(expr, failureMessage: failureMessage)
        } else if _name {
            return raiseException(named: _name!).matches(expr, failureMessage: failureMessage)
        } else {
            return raiseException().matches(expr, failureMessage: failureMessage)
        }
    }

    var named: (name: String) -> KICObjCRaiseExceptionMatcher {
        return ({ name in
            return KICObjCRaiseExceptionMatcher(name: name, reason: self._reason)
        })
    }

    var reason: (reason: String?) -> KICObjCRaiseExceptionMatcher {
        return ({ reason in
            return KICObjCRaiseExceptionMatcher(name: self._name, reason: reason)
        })
    }
}

extension KICObjCMatcher {
    class func raiseExceptionMatcher() -> KICObjCRaiseExceptionMatcher {
        return KICObjCRaiseExceptionMatcher(name: nil, reason: nil)
    }
}
