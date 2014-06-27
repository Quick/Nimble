import Foundation

func beAnInstanceOf(expectedClass: AnyClass) -> FuncMatcherWrapper<NSObject> {
    return DefineMatcher { actualExpression in
        let actualValue = actualExpression.evaluate()
        let message = "be an instance of \(NSStringFromClass(expectedClass))"
        return (actualValue.isKindOfClass(expectedClass), message)
    }
}
