import Foundation

func beAnInstanceOf(expectedClass: AnyClass) -> FuncMatcherWrapper<NSObject> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be an instance of \(NSStringFromClass(expectedClass))"
        return actualExpression.evaluate().isKindOfClass(expectedClass)
    }
}
