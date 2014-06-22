import Foundation

struct _BeAnInstanceOfMatcher: BasicMatcher {
    let expectedClass: AnyClass

    func matches(actualExpression: Expression<NSObject>) -> (pass: Bool, postfix: String)  {
        let actualValue = actualExpression.evaluate()
        let message = "be an instance of \(NSStringFromClass(expectedClass))"
        return (actualValue.isKindOfClass(expectedClass), message)
    }
}

func beAnInstanceOf(expectedClass: AnyClass) -> _BeAnInstanceOfMatcher {
    return _BeAnInstanceOfMatcher(expectedClass: expectedClass)
}
