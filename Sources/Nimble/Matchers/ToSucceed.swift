/**
 Used by the `toSucceed` matcher.

 This is the return type for the closure.
 */
public enum ToSucceedResult {
    case succeeded
    case failed(reason: String)
}

/**
 A Nimble matcher that takes in a closure for validation.

 Return `.succeeded` when the validation succeeds.
 Return `.failed` with a failure reason when the validation fails.
 */
public func succeed() -> NonNilMatcherFunc<() -> ToSucceedResult> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        let optActual = try actualExpression.evaluate()
        guard let actual = optActual  else {
            failureMessage.to = "a"
            failureMessage.postfixMessage = "closure"
            failureMessage.postfixActual = " (use beNil() to match nils)"
            return false
        }

        let result = actual()
        failureMessage.postfixMessage = "succeed"

        switch result {
        case .succeeded:
            failureMessage.actualValue = "<succeeded>"
            return true
        case .failed(let reason):
            failureMessage.actualValue = "<failed> because <\(reason)>"
            return false
        }
    }
}
