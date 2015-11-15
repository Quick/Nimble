import Foundation

public func call(function functionName: String) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            return false
        }
        
        let result = expressionValue.didCall(function: functionName, recordedCallsDescOption: DidCallResultIncludeOption.OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = "call <\(functionName)> from \(expressionValue.dynamicType)"
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return result.success
    }
}
