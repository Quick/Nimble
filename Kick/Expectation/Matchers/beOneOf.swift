import Foundation
import Kick

func beOneOf<T: Equatable>(allowedValues: T[]) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in
        let str = _arrayAsString(allowedValues, joiner: ", ")
        failureMessage.postfixMessage = "be one of: <\(str)>"
        let actualValue = actualExpression.evaluate()
        return contains(allowedValues, actualValue)
    }
}
