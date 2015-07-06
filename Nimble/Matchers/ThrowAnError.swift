public struct ThrowErrorMatcher: Matcher {
    private let closure: ((ErrorType) -> Void)?

    private init() {
        closure = nil
    }
    private init(_ closure: (ErrorType) -> Void) {
        self.closure = closure
    }

    public func matches(actualExpression: Expression<Any>, failureMessage: FailureMessage) throws -> Bool {
        failureMessage.actualValue = nil
        failureMessage.postfixMessage = "throw an error"

        do {
            try actualExpression.evaluate()
        } catch let error {
            failureMessage.actualValue = "<\(error)>"

            if let closure = closure {
                failureMessage.postfixMessage += " that satisfies block"
                let assertions = gatherFailingExpectations {
                    closure(error)
                    return
                }
                let messages = assertions.map { $0.message }
                if messages.count > 0 {
                    return false
                }
            }
            return true
        }
        return false

    }

    public func doesNotMatch(actualExpression: Expression<Any>, failureMessage: FailureMessage) throws -> Bool {
        return try !matches(actualExpression, failureMessage: failureMessage)
    }
}

public func throwAnError(closure: (ErrorType) -> Void) -> ThrowErrorMatcher {
    return ThrowErrorMatcher(closure)
}

public func throwAnError() -> ThrowErrorMatcher {
    return ThrowErrorMatcher()
}