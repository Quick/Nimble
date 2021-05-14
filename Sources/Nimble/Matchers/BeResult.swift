import Foundation

/// A Nimble matcher for Result that succeeds when the actual value is success.
///
/// You can pass a closure to do any arbitrary custom matching to the value inside result.
/// The closure only gets called when the result is success.
public func beSuccess<Success, Failure>(
    test: ((Success) -> Void)? = nil
) -> Predicate<Result<Success, Failure>> {
    return Predicate.define("be <success(\(Success.self))>") { expression, message in
        guard case let .success(value)? = try expression.evaluate() else {
            return PredicateResult(status: .doesNotMatch, message: message)
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

        return PredicateResult(bool: matches, message: message)
    }
}

/// A Nimble matcher for Result that succeeds when the actual value is failure.
///
/// You can pass a closure to do any arbitrary custom matching to the error inside result.
/// The closure only gets called when the result is failure.
public func beFailure<Success, Failure>(
    test: ((Failure) -> Void)? = nil
) -> Predicate<Result<Success, Failure>> {
    return Predicate.define("be <failure(\(Failure.self))>") { expression, message in
        guard case let .failure(error)? = try expression.evaluate() else {
            return PredicateResult(status: .doesNotMatch, message: message)
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

        return PredicateResult(bool: matches, message: message)
    }
}
