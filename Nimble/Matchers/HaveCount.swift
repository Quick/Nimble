import Foundation

public func haveCount<T: Equatable>(expectedValue: Int) -> MatcherFunc<[T]> {
    return MatcherFunc { actualExpression, failureMessage in
        if let actualValue = try actualExpression.evaluate() {
            failureMessage.postfixMessage = "have \(actualValue) with count \(actualValue.count)"
            let result = expectedValue == actualValue.count
            failureMessage.actualValue = "\(expectedValue)"
            return result
        } else {
            return false
        }
    }
}
