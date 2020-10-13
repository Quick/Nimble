/// A Nimble matcher that succeeds when the actual value is within given range.
public func beWithin<T: Comparable>(_ range: Range<T>) -> Predicate<T> {
    let errorMessage = "be within range <(\(range.lowerBound)..<\(range.upperBound))>"
    return Predicate.simple(errorMessage) { actualExpression in
        if let actual = try actualExpression.evaluate() {
            return PredicateStatus(bool: range.contains(actual))
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual value is within given range.
public func beWithin<T: Comparable>(_ range: ClosedRange<T>) -> Predicate<T> {
    let errorMessage = "be within range <(\(range.lowerBound)...\(range.upperBound))>"
    return Predicate.simple(errorMessage) { actualExpression in
        if let actual = try actualExpression.evaluate() {
            return PredicateStatus(bool: range.contains(actual))
        }
        return .fail
    }
}
