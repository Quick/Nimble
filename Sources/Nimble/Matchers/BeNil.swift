/// A protocol which represents whether the value is nil or not.
private protocol _OptionalProtocol {
    var isNil: Bool { get }
}

extension Optional: _OptionalProtocol {
    var isNil: Bool { self == nil }
}

/// A Nimble matcher that succeeds when the actual value is nil.
public func beNil<T>() -> Predicate<T> {
    return Predicate.simpleNilable("be nil") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        if let actual = actualValue, let nestedOptionl = actual as? _OptionalProtocol {
            return PredicateStatus(bool: nestedOptionl.isNil)
        }
        return PredicateStatus(bool: actualValue == nil)
    }
}

/// Represents `nil` value to be used with the operator overloads for `beNil`.
public struct ExpectationNil: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {}
}

extension SyncExpectation {
    public static func == (lhs: SyncExpectation, rhs: ExpectationNil) {
        lhs.to(beNil())
    }

    public static func != (lhs: SyncExpectation, rhs: ExpectationNil) {
        lhs.toNot(beNil())
    }
}

extension AsyncExpectation {
    public static func == (lhs: AsyncExpectation, rhs: ExpectationNil) {
        lhs.to(beNil())
    }

    public static func != (lhs: AsyncExpectation, rhs: ExpectationNil) {
        lhs.toNot(beNil())
    }
}

#if canImport(Darwin)
import Foundation

extension NMBPredicate {
    @objc public class func beNilMatcher() -> NMBPredicate {
        return NMBPredicate { actualExpression in
            return try beNil().satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
