/// A Nimble matcher that succeeds when the actual value is not nil.
public func bePresent<T>() -> Predicate<T> {
    return Predicate.simpleNilable("be present") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return PredicateStatus(bool: actualValue != nil)
    }
}


#if canImport(Darwin)
import Foundation

extension NMBPredicate {
    @objc public class func bePresentMatcher() -> NMBPredicate {
        return NMBPredicate { actualExpression in
            return try bePresent().satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
