public func allPass<S: Sequence>(
    _ passFunc: @escaping (S.Element) async throws -> Bool
) -> AsyncMatcher<S> {
    let matcher = AsyncMatcher<S.Element>.define("pass a condition") { actualExpression, message in
        guard let actual = try await actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: message)
        }
        return MatcherResult(bool: try await passFunc(actual), message: message)
    }
    return createMatcher(matcher)
}

public func allPass<S: Sequence>(
    _ passName: String,
    _ passFunc: @escaping (S.Element) async throws -> Bool
) -> AsyncMatcher<S> {
    let matcher = AsyncMatcher<S.Element>.define(passName) { actualExpression, message in
        guard let actual = try await actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: message)
        }
        return MatcherResult(bool: try await passFunc(actual), message: message)
    }
    return createMatcher(matcher)
}

public func allPass<S: Sequence>(_ elementMatcher: AsyncMatcher<S.Element>) -> AsyncMatcher<S> {
    return createMatcher(elementMatcher)
}

private func createMatcher<S: Sequence>(_ elementMatcher: AsyncMatcher<S.Element>) -> AsyncMatcher<S> {
    return AsyncMatcher { actualExpression in
        guard let actualValue = try await actualExpression.evaluate() else {
            return MatcherResult(
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
            let matcherResult = try await elementMatcher.satisfies(exp)
            if matcherResult.status == .matches {
                failure = matcherResult.message.prepended(expectation: "all ")
            } else {
                failure = matcherResult.message
                    .replacedExpectation({ .expectedTo($0.expectedMessage) })
                    .wrappedExpectation(
                        before: "all ",
                        after: ", but failed first at element <\(stringify(currentElement))>"
                            + " in <\(stringify(actualValue))>"
                )
                return MatcherResult(status: .doesNotMatch, message: failure)
            }
        }
        failure = failure.replacedExpectation({ expectation in
            return .expectedTo(expectation.expectedMessage)
        })
        return MatcherResult(status: .matches, message: failure)
    }
}
