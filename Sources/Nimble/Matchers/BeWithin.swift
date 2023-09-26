/// A Nimble matcher that succeeds when the actual value is within given range.
public func beWithin<T: Comparable>(_ range: Range<T>) -> Matcher<T> {
    let errorMessage = "be within range <(\(range.lowerBound)..<\(range.upperBound))>"
    return Matcher.simple(errorMessage) { actualExpression in
        if let actual = try actualExpression.evaluate() {
            return MatcherStatus(bool: range.contains(actual))
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual value is within given range.
public func beWithin<T: Comparable>(_ range: ClosedRange<T>) -> Matcher<T> {
    let errorMessage = "be within range <(\(range.lowerBound)...\(range.upperBound))>"
    return Matcher.simple(errorMessage) { actualExpression in
        if let actual = try actualExpression.evaluate() {
            return MatcherStatus(bool: range.contains(actual))
        }
        return .fail
    }
}
