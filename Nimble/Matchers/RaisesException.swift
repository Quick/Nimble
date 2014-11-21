import Foundation

internal func raiseExceptionMatcher<T>(message: String, matches: (NSException?) -> Bool) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = message

        // It would be better if this was part of Expression, but
        // Swift compiler crashes when expect() is inside a closure.
        var exception: NSException?
        var result: T?
        var capture = NMBExceptionCapture(handler: ({ e in
            exception = e
            }), finally: nil)

        capture.tryBlock {
            actualExpression.evaluate()
            return
        }
        return matches(exception)
    }
}


/// A Nimble matcher that succeeds when the actual expression raises an exception with
/// the specified name and reason.
public func raiseException(#named: String, #reason: String?) -> MatcherFunc<Any> {
    var theReason = ""
    if let reason = reason {
        theReason = reason
    }
    return raiseExceptionMatcher("raise exception named <\(named)> and reason <\(theReason)>") {
        exception in return exception?.name == named && exception?.reason == reason
    }
}


/// A Nimble matcher that succeeds when the actual expression raises an exception with
/// the specified name.
public func raiseException(#named: String) -> MatcherFunc<Any> {
    return raiseExceptionMatcher("raise exception named <\(named)>") {
        exception in return exception?.name == named
    }
}

/// A Nimble matcher that succeeds when the actual expression raises any exception.
/// Please use a more specific raiseException() matcher when possible.
public func raiseException() -> MatcherFunc<Any> {
    return raiseExceptionMatcher("raise any exception") {
        exception in return exception != nil
    }
}

@objc public class NMBObjCRaiseExceptionMatcher : NMBMatcher {
    var _name: String?
    var _reason: String?
    init(name: String?, reason: String?) {
        _name = name
        _reason = reason
    }

    public func matches(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let block: () -> Any? = ({ actualBlock(); return nil })
        let expr = Expression(expression: block, location: location)
        if _name != nil && _reason != nil {
            return raiseException(named: _name!, reason: _reason).matches(expr, failureMessage: failureMessage)
        } else if _name != nil {
            return raiseException(named: _name!).matches(expr, failureMessage: failureMessage)
        } else {
            return raiseException().matches(expr, failureMessage: failureMessage)
        }
    }

    public func doesNotMatch(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        return !matches(actualBlock, failureMessage: failureMessage, location: location)
    }

    var named: (name: String) -> NMBObjCRaiseExceptionMatcher {
        return ({ name in
            return NMBObjCRaiseExceptionMatcher(name: name, reason: self._reason)
        })
    }

    var reason: (reason: String?) -> NMBObjCRaiseExceptionMatcher {
        return ({ reason in
            return NMBObjCRaiseExceptionMatcher(name: self._name, reason: reason)
        })
    }
}

extension NMBObjCMatcher {
    public class func raiseExceptionMatcher() -> NMBObjCRaiseExceptionMatcher {
        return NMBObjCRaiseExceptionMatcher(name: nil, reason: nil)
    }
}
