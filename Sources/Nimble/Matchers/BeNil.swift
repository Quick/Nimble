import Foundation

/// An empty type signifying nothing.
public struct NilLiteral: NilLiteralConvertible {
    public init(nilLiteral: ()) {}
    public init() {}
}

extension NilLiteral: Equatable {}
public func ==(lhs: NilLiteral, rhs: NilLiteral) -> Bool { return true }

/// Equality operator overload that can be used to simplify
/// nil expectations. For a given expectation `expectThing`,
/// `expectThing == nil` and `expectThing.to(beNil)` are
/// equivalent expressions.
///
/// - SeeAlso: `beNil()`
public func ==<T>(lhs: Expectation<T>, rhs: NilLiteral) {
    lhs.to(beNil())
}

/// Equality operator overload that can be used to simplify
/// nonnil expectations. For a given expectation `expectThing`,
/// `expectThing != nil` and `expectThing.toNot(beNil)` are
/// equivalent expressions.
///
/// - SeeAlso: `beNil()`
public func !=<T>(lhs: Expectation<T>, rhs: NilLiteral) {
    lhs.toNot(beNil())
}

/// A Nimble matcher that succeeds when the actual value is nil.
public func beNil<T>() -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be nil"
        let actualValue = try actualExpression.evaluate()
        return actualValue == nil
    }
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func beNilMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage in
            return try! beNil().matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
#endif
