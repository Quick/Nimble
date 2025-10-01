/// A matcher that negates the passed in matcher
///
/// - Note: If the passed-in matcher unconditionally fails, then `not` also unconditionally fails.
public func not<T>(_ matcher: Matcher<T>) -> Matcher<T> {
    Matcher { actualExpression in
        negateMatcherResult(
            try matcher.satisfies(actualExpression)
        )
    }
}

/// A matcher that negates the passed in matcher
///
/// - Note: If the passed-in matcher unconditionally fails, then `not` also unconditionally fails.
public func not<T>(_ matcher: AsyncMatcher<T>) -> AsyncMatcher<T> {
    AsyncMatcher { actualExpression in
        negateMatcherResult(
            try await matcher.satisfies(actualExpression)
        )
    }
}

private func negateMatcherResult(_ matcherResult: MatcherResult) -> MatcherResult {
    let status: MatcherStatus
    switch matcherResult.status {
    case .matches:
        status = .doesNotMatch
    case .doesNotMatch:
        status = .matches
    case .fail:
        status = .fail
    }
    return MatcherResult(
        status: status,
        message: matcherResult.message.prepended(expectation: "not ")
    )
}
