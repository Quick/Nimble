public func allPass<S: Sequence>(
    _ passFunc: @escaping (S.Element) async throws -> Bool
) -> AsyncPredicate<S> {
    let matcher = AsyncPredicate<S.Element>.define("pass a condition") { actualExpression, message in
        guard let actual = try await actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: message)
        }
        return PredicateResult(bool: try await passFunc(actual), message: message)
    }
    return createPredicate(matcher)
}

public func allPass<S: Sequence>(
    _ passName: String,
    _ passFunc: @escaping (S.Element) async throws -> Bool
) -> AsyncPredicate<S> {
    let matcher = AsyncPredicate<S.Element>.define(passName) { actualExpression, message in
        guard let actual = try await actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: message)
        }
        return PredicateResult(bool: try await passFunc(actual), message: message)
    }
    return createPredicate(matcher)
}

public func allPass<S: Sequence>(_ elementPredicate: AsyncPredicate<S.Element>) -> AsyncPredicate<S> {
    return createPredicate(elementPredicate)
}

private func createPredicate<S: Sequence>(_ elementMatcher: AsyncPredicate<S.Element>) -> AsyncPredicate<S> {
    return AsyncPredicate { actualExpression in
        guard let actualValue = try await actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: .appends(.expectedTo("all pass"), " (use beNil() to match nils)")
            )
        }

        var failure: ExpectationMessage = .expectedTo("all pass")
        for currentElement in actualValue {
            let exp = AsyncExpression(
                expression: { currentElement },
                location: actualExpression.location
            )
            let predicateResult = try await elementMatcher.satisfies(exp)
            if predicateResult.status == .matches {
                failure = predicateResult.message.prepended(expectation: "all ")
            } else {
                failure = predicateResult.message
                    .replacedExpectation({ .expectedTo($0.expectedMessage) })
                    .wrappedExpectation(
                        before: "all ",
                        after: ", but failed first at element <\(stringify(currentElement))>"
                            + " in <\(stringify(actualValue))>"
                )
                return PredicateResult(status: .doesNotMatch, message: failure)
            }
        }
        failure = failure.replacedExpectation({ expectation in
            return .expectedTo(expectation.expectedMessage)
        })
        return PredicateResult(status: .matches, message: failure)
    }
}
