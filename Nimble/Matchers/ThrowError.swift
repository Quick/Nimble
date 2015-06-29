import Foundation

/// A Nimble matcher that succeeds when the actual expression throws an
/// error from the specified case.
///
/// Errors are compared by their _domain and _code.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the thrown error. The closure only gets called when an error was thrown.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func throwError(
    error: ErrorType? = nil,
    closure: ((ErrorType) -> Void)? = nil) -> MatcherFunc<Any> {
        return MatcherFunc { actualExpression, failureMessage in

            var actualError: ErrorType?
            do {
                try actualExpression.evaluate()
            } catch let catchedError {
                actualError = catchedError
            }

            setFailureMessageForError(failureMessage, actualError: actualError, error: error, closure: closure)
            return errorMatchesNonNilFieldsOrClosure(actualError, error: error, closure: closure)
        }
}

internal func setFailureMessageForError(
    failureMessage: FailureMessage,
    actualError: ErrorType?,
    error: ErrorType?,
    closure: ((ErrorType) -> Void)?) {
        failureMessage.postfixMessage = "throw error"

        if let error = error {
            if let error = error as? CustomDebugStringConvertible {
                failureMessage.postfixMessage += " <\(error.debugDescription)>"
            } else {
                failureMessage.postfixMessage += " <\(error)>"
            }
        }
        if let _ = closure {
            failureMessage.postfixMessage += " that satisfies block"
        }
        if error == nil && closure == nil {
            failureMessage.postfixMessage = "throw any error"
        }

        if let actualError = actualError {
            failureMessage.actualValue = "<\(actualError)>"
        } else {
            failureMessage.actualValue = "no error"
        }
}

internal func errorMatchesExpectedError(
    actualError: ErrorType,
    expectedError: ErrorType) -> Bool {
        //return "\(actualError)" == "\(expectedError)"
        return actualError._domain == expectedError._domain
            && actualError._code   == expectedError._code
}

internal func errorMatchesNonNilFieldsOrClosure(
    actualError: ErrorType?,
    error: ErrorType?,
    closure: ((ErrorType) -> Void)?) -> Bool {
        var matches = false

        if let actualError = actualError {
            matches = true

            if let error = error {
                if !errorMatchesExpectedError(actualError, expectedError: error) {
                    matches = false
                }
            }
            if let closure = closure {
                let assertions = gatherFailingExpectations {
                    closure(actualError)
                }
                let messages = assertions.map { $0.message }
                if messages.count > 0 {
                    matches = false
                }
            }
        }
        
        return matches
}
