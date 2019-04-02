import Foundation

///
/// A Nimble matcher for Result that succeeds when the actual value is success
///
/// You can pass a closure to do any arbitrary custom matching
/// to the value inside result. The closure only gets called when result is success.
public func beSuccess<T>(test: ((T) -> Void)? = nil) -> Predicate<Result<T, Error>> {
    return Predicate.define("be <success>") { expression, message in
        guard case let .success(value)? = try expression.evaluate()
        else {
            return PredicateResult(status: .doesNotMatch, message: message)
        }
        test?(value)
        return PredicateResult(status: .matches, message: message)
    }
}

///
/// A Nimble matcher for Result that succeeds when the actual value is failure
///
/// You can pass a closure to do custom matching for the error inside result.
/// The closure only gets called when result is failure.
public func beFailure<T>(test: ((Error) -> Void)? = nil) -> Predicate<Result<T, Error>> {
    return Predicate.define("be <failure>") { expression, message in
        guard case let .failure(error)? = try expression.evaluate()
        else {
            return PredicateResult(status: .doesNotMatch, message: message)
        }
        test?(error)
        return PredicateResult(status: .matches, message: message)
    }
}
