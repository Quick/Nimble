import Foundation

/// A Nimble matcher that succeeds when the actual value is an _exact_ instance of the given class.
public func beAnInstanceOf<T, U>(_ expectedType: T.Type) -> Matcher<U> {
    return Matcher.define { actualExpression in
        let instance = try actualExpression.evaluate()
        guard let validInstance: Any = instance else {
            return MatcherResult(
                status: .doesNotMatch,
                message: .expectedActualValueTo("be an instance of \(String(describing: expectedType))")
            )
        }

        return MatcherResult(
            status: MatcherStatus(bool: type(of: validInstance) == expectedType),
            message: .expectedCustomValueTo(
                "be an instance of \(String(describing: expectedType))",
                actual: "<\(String(describing: type(of: validInstance))) instance>"
            )
        )
    }
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAKindOf if you want to match against subclasses
public func beAnInstanceOf(_ expectedClass: AnyClass) -> Matcher<NSObject> {
    return Matcher.define { actualExpression in
        let instance = try actualExpression.evaluate()
        #if canImport(Darwin)
            let matches = instance != nil && instance!.isMember(of: expectedClass)
        #else
            let matches = instance != nil && type(of: instance!) == expectedClass
        #endif
        return MatcherResult(
            status: MatcherStatus(bool: matches),
            message: .expectedCustomValueTo(
                "be an instance of \(String(describing: expectedClass))",
                actual: instance.map { "<\(String(describing: type(of: $0))) instance>" } ?? "<nil>"
            )
        )
    }
}

#if canImport(Darwin)
extension NMBMatcher {
    @objc public class func beAnInstanceOfMatcher(_ expected: AnyClass) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            return try beAnInstanceOf(expected).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
