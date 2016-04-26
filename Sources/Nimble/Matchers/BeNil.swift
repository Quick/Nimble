import Foundation

public let Nil = NilLiteral()

public struct NilLiteral: NilLiteralConvertible {
    public init(nilLiteral: ()) {}
    public init() {}
}

extension NilLiteral: Equatable {}
public func ==(lhs: NilLiteral, rhs: NilLiteral) -> Bool { return true }

public func ==<T>(lhs: Expectation<T>, rhs: NilLiteral) {
    lhs.to(beNil())
}

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
