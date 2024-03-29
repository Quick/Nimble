import Foundation

/// A Nimble matcher for Result that succeeds when the actual value is success.
///
/// You can pass a closure to do any arbitrary custom matching to the value inside result.
/// The closure only gets called when the result is success.
public func beSuccess<Success, Failure>(
    test: ((Success) -> Void)? = nil
) -> Matcher<Result<Success, Failure>> {
    return Matcher.define { expression in
        var rawMessage = "be <success(\(Success.self))>"
        if test != nil {
            rawMessage += " that satisfies block"
        }
        let message = ExpectationMessage.expectedActualValueTo(rawMessage)

        guard case let .success(value)? = try expression.evaluate() else {
            return MatcherResult(status: .doesNotMatch, message: message)
        }

        var matches = true
        if let test = test {
            let assertions = gatherFailingExpectations {
                test(value)
            }
            let messages = assertions.map { $0.message }
            if !messages.isEmpty {
                matches = false
            }
        }

        return MatcherResult(bool: matches, message: message)
    }
}

/// A Nimble matcher for Result that succeeds when the actual value is success
/// and the value inside result is equal to the expected value
public func beSuccess<Success, Failure>(
    _ value: Success
) -> Matcher<Result<Success, Failure>> where Success: Equatable {
    return Matcher.define { expression in
        let message = ExpectationMessage.expectedActualValueTo(
            "be <success(\(Success.self))> that equals \(stringify(value))"
        )

        guard case let .success(resultValue)? = try expression.evaluate() else {
            return MatcherResult(status: .doesNotMatch, message: message)
        }

        return MatcherResult(
            bool: resultValue == value,
            message: message
        )
    }
}

/// A Nimble matcher for Result that succeeds when the actual value is success
/// and the provided matcher matches.
public func beSuccess<Success, Failure>(
    _ matcher: Matcher<Success>
) -> Matcher<Result<Success, Failure>> {
    return Matcher.define { expression in
        let message = ExpectationMessage.expectedActualValueTo(
            "be <success(\(Success.self))> that satisfies matcher"
        )

        guard case let .success(value)? = try expression.evaluate() else {
            return MatcherResult(status: .doesNotMatch, message: message)
        }

        let subExpression = Expression(
            expression: { value },
            location: expression.location
        )
        let subResult = try matcher.satisfies(subExpression)

        let matches = subResult.toBoolean(expectation: .toMatch)

        return MatcherResult(
            bool: matches,
            message: message.appended(
                details: subResult.message.toString(
                    actual: stringify(value)
                )
            )
        )
    }
}

/// A Nimble matcher for Result that succeeds when the actual value is failure.
///
/// You can pass a closure to do any arbitrary custom matching to the error inside result.
/// The closure only gets called when the result is failure.
public func beFailure<Success, Failure>(
    test: ((Failure) -> Void)? = nil
) -> Matcher<Result<Success, Failure>> {
    return Matcher.define { expression in
        var rawMessage = "be <failure(\(Failure.self))>"
        if test != nil {
            rawMessage += " that satisfies block"
        }
        let message = ExpectationMessage.expectedActualValueTo(rawMessage)

        guard case let .failure(error)? = try expression.evaluate() else {
            return MatcherResult(status: .doesNotMatch, message: message)
        }

        var matches = true
        if let test = test {
            let assertions = gatherFailingExpectations {
                test(error)
            }
            let messages = assertions.map { $0.message }
            if !messages.isEmpty {
                matches = false
            }
        }

        return MatcherResult(bool: matches, message: message)
    }
}

/// A Nimble matcher for Result that succeeds when the actual value is failure
/// and the provided matcher matches.
public func beFailure<Success, Failure>(
    _ matcher: Matcher<Failure>
) -> Matcher<Result<Success, Failure>> {
    return Matcher.define { expression in
        let message = ExpectationMessage.expectedActualValueTo(
            "be <failure(\(Failure.self))> that satisfies matcher"
        )

        guard case let .failure(error)? = try expression.evaluate() else {
            return MatcherResult(status: .doesNotMatch, message: message)
        }

        let subExpression = Expression(
            expression: { error },
            location: expression.location
        )
        let subResult = try matcher.satisfies(subExpression)

        let matches = subResult.toBoolean(expectation: .toMatch)

        return MatcherResult(
            bool: matches,
            message: message.appended(
                details: subResult.message.toString(
                    actual: stringify(error)
                )
            )
        )
    }
}
