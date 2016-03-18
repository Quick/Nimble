import Foundation

public func throwAssertion() -> MatcherFunc<Void> {
    return MatcherFunc { actualExpression, failureMessage in
    #if arch(x86_64) && _runtime(_ObjC) && !os(tvOS)
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
    #elseif os(tvOS)
        fatalError("The throwAssertion Nimble matcher does not currently support tvOS targets")
    #else
        fatalError("The throwAssertion Nimble matcher can only run on x86_64 platforms with " +
            "Objective-C (e.g. Mac, iPhone 5s or later simulators). You can silence this error " +
            "by placing the test case inside an #if arch(x86_64) or _runtime(_ObjC) conditional statement")
    #endif
    }
}