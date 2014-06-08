import Foundation

struct _BeAnInstanceOf: Matcher {
    let expectedClass: AnyClass

    func matches(actualExpression: Expression<NSObject>) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression.evaluateIfNeeded()
        let message = "be an instance of \(NSStringFromClass(expectedClass))"
        return (actualValue.isKindOfClass(expectedClass), message)
    }
}

func beAnInstanceOf(expectedClass: AnyClass) -> _BeAnInstanceOf {
    return _BeAnInstanceOf(expectedClass: expectedClass)
}
