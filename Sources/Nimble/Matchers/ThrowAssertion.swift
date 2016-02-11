import Foundation

public func throwAssertion() -> MatcherFunc<Void> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "throw an assertion"
        failureMessage.actualValue = nil
        
        var succeeded = true
        
        let caughtException: BadInstructionException? = catchBadInstruction {
            do {
                try actualExpression.evaluate()
            } catch let error {
                succeeded = false
                failureMessage.postfixMessage += "; threw error instead <\(error)>"
            }
        }

        if !succeeded {
            return false
        }
        
        if caughtException == nil {
            return false
        }
        
        return true
    }
}
