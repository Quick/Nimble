import Foundation

#if !os(tvOS)

public func throwAssertion() -> MatcherFunc<Void> {
    return MatcherFunc { actualExpression, failureMessage in
    #if arch(x86_64) && _runtime(_ObjC)
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
    #else
        fatalError("The throwAssertion Nimble matcher can only run on x86_64 platforms with Objective-C (e.g. Mac, iPhone 5s or later simulators)")
    #endif
    }
}


#endif