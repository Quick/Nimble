public enum ToSucceedResult {
    case succeeded
    case failed(reason: String)
}

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
